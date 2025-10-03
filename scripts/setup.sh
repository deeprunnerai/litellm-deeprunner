#!/bin/bash

# LiteLLM DeepRunner.ai Deployment Script
# This script automates the deployment of LiteLLM with PostgreSQL, Ollama, and Nginx

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ $1${NC}"; }

# Check if running as root
check_root() {
    # Allow root for initial deployment, will create non-root user later if needed
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root - this is OK for initial setup"
    fi
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker found"

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    print_success "Docker Compose found"

    # Check if .env exists
    if [ ! -f .env ]; then
        print_error ".env file not found. Please create it from .env.template"
        print_info "Run: cp .env.template .env"
        print_info "Then edit .env with your configuration"
        exit 1
    fi
    print_success ".env file found"
}

# Generate secure keys
generate_keys() {
    print_info "Checking for secure keys in .env..."

    if grep -q "CHANGE_ME" .env; then
        print_warning "Found CHANGE_ME placeholders in .env file"
        read -p "Do you want to generate secure keys automatically? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            MASTER_KEY=$(openssl rand -hex 32)
            SALT_KEY=$(openssl rand -hex 32)
            DB_PASSWORD=$(openssl rand -hex 16)
            UI_PASSWORD=$(openssl rand -hex 12)

            sed -i.bak "s/LITELLM_MASTER_KEY=.*/LITELLM_MASTER_KEY=sk-${MASTER_KEY}/" .env
            sed -i.bak "s/LITELLM_SALT_KEY=.*/LITELLM_SALT_KEY=${SALT_KEY}/" .env
            sed -i.bak "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=${DB_PASSWORD}/" .env
            sed -i.bak "s/UI_PASSWORD=.*/UI_PASSWORD=${UI_PASSWORD}/" .env

            print_success "Generated secure keys"
            print_warning "Backup saved as .env.bak"
        fi
    else
        print_success "Keys already configured"
    fi
}

# Setup SSL certificates
setup_ssl() {
    print_info "Setting up SSL certificates..."

    # Check if Let's Encrypt certificates already exist
    if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
        print_success "Let's Encrypt certificates found for $DOMAIN"
        return 0
    fi

    print_warning "SSL certificates not found"
    print_info "Options:"
    echo "  1. Use self-signed certificate (for testing)"
    echo "  2. Use Let's Encrypt (requires domain pointing to this server)"
    echo "  3. Skip SSL setup (configure manually later)"
    read -p "Choose option (1-3): " ssl_option

    case $ssl_option in
        1)
            print_info "Generating self-signed certificate..."
            mkdir -p config/ssl
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout config/ssl/privkey.pem \
                -out config/ssl/fullchain.pem \
                -subj "/C=US/ST=State/L=City/O=DeepRunner/CN=${DOMAIN}"
            print_success "Self-signed certificate created"
            ;;
        2)
            setup_letsencrypt
            ;;
        3)
            print_warning "Skipping SSL setup. Configure manually before production use."
            mkdir -p config/ssl
            touch config/ssl/privkey.pem config/ssl/fullchain.pem
            ;;
    esac
}

# Setup Let's Encrypt SSL
setup_letsencrypt() {
    print_info "Setting up Let's Encrypt SSL..."

    # Check if certbot is installed
    if ! command -v certbot &> /dev/null; then
        print_info "Installing certbot..."
        apt update
        apt install certbot -y
        print_success "Certbot installed"
    fi

    # Create webroot directory
    mkdir -p /var/www/certbot
    print_success "Webroot directory created"

    # Get domain from .env
    DOMAIN=$(grep DOMAIN= .env | cut -d '=' -f2)
    ADMIN_EMAIL=$(grep ADMIN_EMAIL= .env | cut -d '=' -f2)

    if [ -z "$DOMAIN" ] || [ -z "$ADMIN_EMAIL" ]; then
        print_error "DOMAIN or ADMIN_EMAIL not set in .env file"
        print_info "Please configure these values and run setup again"
        return 1
    fi

    print_info "Obtaining certificate for: $DOMAIN"
    print_info "Admin email: $ADMIN_EMAIL"

    # Initial certificate with standalone (nginx not running yet)
    certbot certonly --standalone \
        --non-interactive \
        --agree-tos \
        --email "$ADMIN_EMAIL" \
        -d "$DOMAIN" \
        --preferred-challenges http

    if [ $? -eq 0 ]; then
        print_success "Certificate obtained successfully"

        # Reconfigure for webroot renewal
        print_info "Configuring webroot renewal..."
        certbot certonly --webroot \
            -w /var/www/certbot \
            --force-renewal \
            --non-interactive \
            --agree-tos \
            --email "$ADMIN_EMAIL" \
            -d "$DOMAIN"

        print_success "Auto-renewal configured with webroot method"
        print_info "Certificate will auto-renew via systemd timer (certbot.timer)"
    else
        print_error "Failed to obtain certificate"
        print_info "Falling back to self-signed certificate"
        mkdir -p config/ssl
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout config/ssl/privkey.pem \
            -out config/ssl/fullchain.pem \
            -subj "/C=US/ST=State/L=City/O=DeepRunner/CN=${DOMAIN}"
    fi
}

# Initialize Ollama
init_ollama() {
    print_info "Initializing Ollama with Mistral model..."

    # Wait for Ollama to be ready
    print_info "Waiting for Ollama service to start..."
    sleep 10

    # Pull Mistral model
    docker exec litellm-ollama ollama pull mistral
    print_success "Mistral model downloaded"
}

# Create data directories
setup_directories() {
    print_info "Creating data directories..."
    mkdir -p data/postgres data/ollama config/ssl
    chmod 700 data/postgres
    print_success "Directories created"
}

# Deploy services
deploy() {
    print_info "Deploying services..."

    # Pull latest images
    print_info "Pulling Docker images..."
    docker-compose pull

    # Start services
    print_info "Starting services..."
    docker-compose up -d postgres ollama

    # Wait for PostgreSQL
    print_info "Waiting for PostgreSQL to be ready..."
    sleep 10

    # Start LiteLLM
    docker-compose up -d litellm
    sleep 5

    # Initialize Ollama
    init_ollama

    # Start Nginx
    docker-compose up -d nginx

    print_success "All services deployed"
}

# Health check
health_check() {
    print_info "Running health checks..."

    # Check if containers are running
    if docker ps | grep -q "litellm-postgres"; then
        print_success "PostgreSQL is running"
    else
        print_error "PostgreSQL is not running"
    fi

    if docker ps | grep -q "litellm-ollama"; then
        print_success "Ollama is running"
    else
        print_error "Ollama is not running"
    fi

    if docker ps | grep -q "litellm-proxy"; then
        print_success "LiteLLM is running"
    else
        print_error "LiteLLM is not running"
    fi

    if docker ps | grep -q "litellm-nginx"; then
        print_success "Nginx is running"
    else
        print_error "Nginx is not running"
    fi
}

# Display info
display_info() {
    echo ""
    print_success "=========================================="
    print_success "LiteLLM Deployment Complete!"
    print_success "=========================================="
    echo ""
    print_info "Access URLs:"
    echo "  • LiteLLM Admin UI: https://your-domain/ui"
    echo "  • Analytics Dashboard: https://your-domain/dashboard"
    echo "  • API Endpoint: https://your-domain"
    echo ""
    print_info "Credentials:"
    echo "  • UI Username: $(grep UI_USERNAME .env | cut -d '=' -f2)"
    echo "  • UI Password: Check .env file"
    echo "  • Master Key: Check .env file"
    echo ""
    print_info "Useful commands:"
    echo "  • View logs: docker-compose logs -f"
    echo "  • Restart: docker-compose restart"
    echo "  • Stop: docker-compose down"
    echo "  • Update: docker-compose pull && docker-compose up -d"
    echo ""
    print_warning "Next steps:"
    echo "  1. Configure your domain DNS to point to this server"
    echo "  2. Setup Let's Encrypt SSL (see docs/DEPLOYMENT.md)"
    echo "  3. Configure M365 OAuth (see docs/M365_OAUTH_SETUP.md)"
    echo "  4. Add LLM provider API keys to .env"
    echo ""
}

# Main execution
main() {
    echo "=========================================="
    echo "LiteLLM DeepRunner.ai Deployment"
    echo "=========================================="
    echo ""

    check_root
    check_prerequisites
    generate_keys
    setup_directories
    setup_ssl
    deploy
    sleep 5
    health_check
    display_info
}

# Run main function
main
