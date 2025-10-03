# LiteLLM Deployment Guide - DeepRunner.ai

Complete guide for deploying LiteLLM with PostgreSQL, Ollama, and Nginx on DigitalOcean.

## Prerequisites

- DigitalOcean account
- Domain name (e.g., `litellm.deeprunner.ai`)
- API keys for LLM providers (OpenAI, Anthropic, etc.)
- Microsoft 365 admin access (for OAuth setup)

## 1. Provision DigitalOcean Droplet

### Recommended Specifications
- **Type**: CPU-Optimized Droplet
- **Size**: 4 vCPU / 8GB RAM / 100GB SSD
- **OS**: Ubuntu 22.04 LTS
- **Cost**: ~$84/month

### Create Droplet
1. Go to DigitalOcean dashboard
2. Click "Create" → "Droplets"
3. Select Ubuntu 22.04 LTS
4. Choose CPU-Optimized 4vCPU / 8GB plan
5. Select datacenter region (closest to your users)
6. Add SSH key for authentication
7. Create droplet

## 2. Initial Server Setup

### Connect to Droplet
```bash
ssh root@YOUR_DROPLET_IP
```

### Update System
```bash
apt update && apt upgrade -y
```

### Create Non-Root User
```bash
adduser deeprunner
usermod -aG sudo deeprunner
```

### Setup SSH for New User
```bash
rsync --archive --chown=deeprunner:deeprunner ~/.ssh /home/deeprunner
```

### Configure Firewall
```bash
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### Install Fail2Ban (Security)
```bash
apt install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban
```

## 3. Install Docker & Docker Compose

### Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker deeprunner
```

### Install Docker Compose
```bash
apt install docker-compose-plugin -y
```

### Verify Installation
```bash
docker --version
docker compose version
```

## 4. Deploy LiteLLM Stack

### Switch to Non-Root User
```bash
su - deeprunner
```

### Clone Repository (or Upload Files)
```bash
# Option 1: If using git
git clone <your-repo-url>
cd litellm-deeprunner

# Option 2: Upload via SCP from local machine
# scp -r litellm-deeprunner deeprunner@YOUR_DROPLET_IP:~/
```

### Configure Environment
```bash
cp .env.template .env
nano .env
```

See `.env.template` for all required configuration. Key items:
- Database password, LiteLLM master/salt keys (generate with `openssl rand -hex 32`)
- Domain and admin email for SSL
- LLM provider API keys

### Run Deployment Script
```bash
cd ~/litellm-deeprunner
chmod +x scripts/setup.sh
./scripts/setup.sh
```

The script will:
- Check prerequisites
- Generate secure keys (if needed)
- Setup SSL certificates
- Start all services (PostgreSQL, Ollama, LiteLLM, Nginx)
- Download Mistral model for Ollama
- Run health checks

## 5. DNS Configuration

### Point Domain to Droplet
1. Go to your DNS provider (e.g., Cloudflare, GoDaddy)
2. Add A record:
   - **Name**: `litellm` (or `@` for root domain)
   - **Value**: `YOUR_DROPLET_IP`
   - **TTL**: 300 (or Auto)
3. Wait for DNS propagation (5-30 minutes)

### Verify DNS
```bash
dig litellm.deeprunner.ai
# or
nslookup litellm.deeprunner.ai
```

## 6. Setup Let's Encrypt SSL

### Install Certbot
```bash
sudo apt update
sudo apt install certbot -y
```

### Create Webroot Directory
```bash
sudo mkdir -p /var/www/certbot
```

### Update Nginx Configuration
The nginx configuration is already set up to serve ACME challenges from `/var/www/certbot` at the `/.well-known/acme-challenge/` location.

### Stop Nginx Temporarily (First Time Only)
```bash
docker compose stop nginx
```

### Obtain Certificate (First Time - Standalone)
```bash
sudo certbot certonly --standalone \
  --non-interactive \
  --agree-tos \
  --email devops@deeprunner.ai \
  -d prod.litellm.deeprunner.ai \
  --preferred-challenges http
```

### Reconfigure for Webroot Renewal
```bash
# Stop nginx temporarily
docker compose stop nginx

# Create webroot directory
sudo mkdir -p /var/www/certbot

# Get certificate with webroot method (this updates renewal config)
sudo certbot certonly --webroot \
  -w /var/www/certbot \
  --force-renewal \
  --non-interactive \
  --agree-tos \
  --email devops@deeprunner.ai \
  -d prod.litellm.deeprunner.ai

# Start nginx
docker compose up -d nginx
```

### Verify Auto-Renewal Configuration
Certbot automatically sets up a systemd timer for renewals. Verify it:
```bash
sudo systemctl status certbot.timer
```

The timer runs twice daily and will automatically renew certificates when they're within 30 days of expiration.

### Test Renewal (Dry Run)
```bash
sudo certbot renew --dry-run
```

**Note**: The renewal uses webroot method, so nginx must be running. The certificates are mounted directly from `/etc/letsencrypt` into the nginx container, so no manual copying is needed.

### Manual Renewal (if needed)
```bash
sudo certbot renew
docker compose restart nginx
```

## 7. Verify Deployment

### Check Service Status
```bash
docker ps
```

You should see 4 containers running:
- `litellm-postgres`
- `litellm-ollama`
- `litellm-proxy`
- `litellm-nginx`

### Test Endpoints
```bash
# Health check
curl https://litellm.deeprunner.ai/health

# Admin UI (in browser)
# https://litellm.deeprunner.ai/ui

# Analytics Dashboard (in browser)
# https://litellm.deeprunner.ai/dashboard
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f litellm
```

## 8. Configure M365 OAuth

See [M365_OAUTH_SETUP.md](./M365_OAUTH_SETUP.md) for detailed instructions.

## 9. Test API

Test the API using cURL or the OpenAI SDK. See [LiteLLM API docs](https://docs.litellm.ai/docs/proxy/user_keys) for complete examples.

Basic test:
```bash
curl https://litellm.deeprunner.ai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -d '{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "Hello!"}]}'
```

## 10. Backup & Maintenance

### Backup PostgreSQL
```bash
# Create backup directory
mkdir -p ~/backups

# Backup database
docker exec litellm-postgres pg_dump -U litellm_user litellm > ~/backups/litellm_$(date +%Y%m%d).sql
```

### Setup Automated Backups
```bash
# Create backup script
cat > ~/backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=~/backups
mkdir -p $BACKUP_DIR
docker exec litellm-postgres pg_dump -U litellm_user litellm > $BACKUP_DIR/litellm_$(date +%Y%m%d_%H%M%S).sql
# Keep only last 7 days
find $BACKUP_DIR -name "litellm_*.sql" -mtime +7 -delete
EOF

chmod +x ~/backup-db.sh

# Add to crontab (daily at 2am)
(crontab -l 2>/dev/null; echo "0 2 * * * ~/backup-db.sh") | crontab -
```

### Update Services
```bash
cd ~/litellm-deeprunner
docker-compose pull
docker-compose up -d
```

### View Resource Usage
```bash
docker stats
```

## Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose logs <service-name>

# Restart service
docker-compose restart <service-name>
```

### PostgreSQL Connection Issues
```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Verify database
docker exec -it litellm-postgres psql -U litellm_user -d litellm
```

### Ollama Model Issues
```bash
# Check Ollama logs
docker-compose logs ollama

# Re-download model
docker exec litellm-ollama ollama pull mistral
```

### SSL Certificate Issues
```bash
# Check certificate validity
openssl x509 -in config/ssl/fullchain.pem -text -noout

# Test SSL
curl -v https://litellm.deeprunner.ai
```

## Security Best Practices

1. **Change Default Passwords**: Update all passwords in `.env`
2. **Restrict SSH**: Disable password authentication, use SSH keys only
3. **Keep Updated**: Regularly update system and Docker images
4. **Monitor Logs**: Check logs for suspicious activity
5. **Backup Regularly**: Automate database backups
6. **Use Firewall**: Keep UFW enabled with minimal open ports
7. **Enable Fail2Ban**: Protect against brute-force attacks
8. **Rotate Keys**: Periodically rotate API keys and master keys

## Useful Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart specific service
docker-compose restart litellm

# View logs
docker-compose logs -f

# View running containers
docker ps

# Execute command in container
docker exec -it litellm-proxy sh

# Check disk usage
df -h

# Check memory usage
free -h

# Monitor resource usage
htop
```

## Support

For issues or questions:
1. Check logs: `docker-compose logs`
2. Review LiteLLM docs: https://docs.litellm.ai
3. Check Ollama docs: https://ollama.ai/docs
4. Contact: admin@deeprunner.ai
