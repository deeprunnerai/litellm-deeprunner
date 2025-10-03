# Changelog

All notable changes to the LiteLLM DeepRunner.ai deployment will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### In Progress - 2025-10-04
**Production Deployment Preparation**

#### Next Steps
- Deploy to production with updated configuration
- Uncomment HTTPS server block for production
- Test end-to-end OAuth flow on production

---

## [0.2.0] - 2025-10-04

### Added - Local Development & Database Admin

#### Features
- **pgAdmin Integration**:
  - Added pgAdmin4 container for database administration
  - Direct access at http://localhost:8081/browser/
  - Nginx reverse proxy at /pgadmin/ path
  - Persistent data storage in data/pgadmin/
  - Login via ADMIN_EMAIL and UI_PASSWORD from .env

- **Admin Role Management**:
  - Created scripts/set-admin-role.sh for setting user as proxy_admin
  - Automatic database query to update user role
  - Simplified admin onboarding process

- **Local Development Configuration**:
  - Added localhost server block in nginx.conf (port 8080)
  - Commented out HTTPS server block for local development
  - Configured pgAdmin proxy through Nginx
  - Multiple access points for flexibility

#### Changed
- **Environment Variables**:
  - Added MICROSOFT_TENANT (in addition to MICROSOFT_TENANT_ID)
  - Required for LiteLLM OAuth to work properly
  - Updated .env with both variables

- **docker-compose.yml**:
  - Added pgAdmin4 service
  - Removed direct port mapping for pgAdmin (now proxied via Nginx)
  - pgAdmin accessible only through Nginx for security

- **config/nginx.conf**:
  - Added upstream pgadmin_backend configuration
  - Added /pgadmin/ location block with proper headers
  - Created separate server block for localhost (development)
  - Commented HTTPS server block (production-only)

- **config/litellm-config.yaml**:
  - Added litellm_proxy_admin_id configuration
  - Set gaurav@deeprunner.ai as admin

#### Documentation
- **README.md**:
  - Added Local Development section with step-by-step guide
  - Added Database Administration section with pgAdmin instructions
  - Updated Project Structure to include pgAdmin
  - Added Azure AD redirect URI configuration steps
  - Separated local and production deployment instructions

- **TASKS.md**:
  - Added Phase 2: Local Development Environment (completed)
  - Updated status to "Local Development Environment Ready"
  - Added new tasks for production deployment
  - Moved completed tasks to proper sections

#### Infrastructure
- **Droplet Provisioned**: 46.101.121.227
  - Type: Premium AMD (DigitalOcean)
  - Specs: 4GB RAM / 2 vCPU / 80GB NVMe SSD
  - Cost: $28/month
  - Hostname: litellm-prod-01
  - OS: Ubuntu 24.04 LTS

- **SSH Access Configured**:
  - Key: ~/.ssh/deeprunner_litellm
  - Alias: litellm-droplet
  - Connection verified

#### Security
- **OAuth Configuration**:
  - Microsoft 365 OAuth fully configured
  - Azure AD redirect URIs added for local and production
  - SSO login flow tested and working
  - Admin role properly assigned via database

#### Current Status (2025-10-04)
**Completed**:
- Local development environment fully functional
- Microsoft 365 OAuth authentication working
- pgAdmin database administration accessible
- Admin access configured and tested
- Documentation updated

**Ready For**:
- Production deployment with current configuration

---

## [0.1.1] - 2025-10-04

### Added - Scaling & Optimization

#### Documentation
- **docs/SCALING_GUIDE.md**: Comprehensive scaling documentation
  - Entry-level ($28) vs production ($84) vs HA ($250+) comparison
  - Monitoring commands and resource optimization tips
  - Upgrade decision matrix and process
  - Emergency actions for resource constraints

#### Changed
- **docker-compose.yml**: Optimized for 4GB RAM droplet
  - Reduced LiteLLM workers from 4 to 2
  - Added Ollama memory limit (2GB max)
  - Set OLLAMA_NUM_PARALLEL=1 (single concurrent request)
  - Set OLLAMA_MAX_LOADED_MODELS=1 (conserve memory)
  - Removed GPU configuration (CPU-only droplet)

### Planned
- Terraform configuration for infrastructure as code
- Prometheus + Grafana monitoring stack
- Redis caching layer
- Multi-droplet load balancing setup
- Automated backup to DigitalOcean Spaces

---

## [0.1.0] - 2025-10-03

### Added - Initial Setup

#### Infrastructure
- Docker Compose configuration with 4 services:
  - PostgreSQL 16 (Alpine) for data persistence
  - Ollama (latest) for local LLM (Mistral)
  - LiteLLM (main-latest) proxy server
  - Nginx (Alpine) reverse proxy
- Network isolation (litellm-network bridge)
- Persistent volumes for PostgreSQL and Ollama data
- Health checks for all services

#### Configuration Files
- **config/litellm-config.yaml**:
  - Multi-provider support (OpenAI, Anthropic, Azure, Ollama)
  - 9 pre-configured models (GPT-4, Claude-3, Mistral)
  - Microsoft 365 OAuth/SSO integration
  - Role-based access control (Admin, DevOps, Team Members)
  - Request/response logging to PostgreSQL
  - Rate limiting and timeout settings

- **config/nginx.conf**:
  - HTTP to HTTPS redirect
  - SSL/TLS configuration (TLS 1.2/1.3)
  - Security headers (HSTS, X-Frame-Options, CSP)
  - Rate limiting (10 req/s for API, 5 req/s for dashboard)
  - Proxy configuration for LiteLLM backend
  - Long timeout for LLM requests (600s)
  - Gzip compression

- **.env.template**:
  - PostgreSQL credentials
  - LiteLLM master key and salt key
  - Admin UI credentials
  - M365 OAuth configuration
  - LLM provider API keys
  - Domain and email configuration

#### Scripts
- **scripts/setup.sh**:
  - Automated deployment script
  - Prerequisite checking (Docker, Docker Compose)
  - Secure key generation (OpenSSL)
  - SSL certificate setup (self-signed or Let's Encrypt)
  - Service deployment and health checks
  - Ollama model initialization
  - Colored terminal output with status indicators

#### Dashboard
- **dashboard/index.html**:
  - Custom 1-page analytics dashboard
  - Real-time metrics display (requests, tokens, latency, users, errors, cost)
  - Provider usage bar chart
  - Model distribution chart
  - Recent activity table
  - Dark theme optimized for readability
  - Auto-refresh every 30 seconds

#### Documentation
- **README.md**: Project overview, quick start, API usage examples
- **docs/DEPLOYMENT.md**: Complete deployment guide with:
  - DigitalOcean droplet setup instructions
  - Server hardening steps (firewall, fail2ban)
  - Docker installation
  - DNS configuration
  - Let's Encrypt SSL setup with auto-renewal
  - Backup automation
  - Troubleshooting guide
  - Security best practices

- **docs/M365_OAUTH_SETUP.md**: Microsoft 365 OAuth configuration with:
  - Azure AD app registration steps
  - Client secret generation
  - API permissions setup
  - Security group creation
  - Role-based access configuration
  - Conditional access policies
  - Testing and troubleshooting

- **CLAUDE.md**: AI assistant instructions for project maintenance
- **TASKS.md**: Task tracking and project roadmap
- **CHANGELOG.md**: This file

#### Security
- **.gitignore**: Comprehensive exclusion list:
  - Environment files (.env)
  - Data directories (postgres, ollama)
  - SSL certificates
  - Logs and backups
  - OS and editor files

- Security features implemented:
  - Secrets via environment variables (never committed)
  - PostgreSQL data encryption at rest
  - Ollama network isolation (no external access)
  - HTTPS-only with modern TLS
  - Rate limiting on all endpoints
  - Security headers (HSTS, CSP, etc.)
  - Firewall configuration (UFW)
  - Fail2ban for brute-force protection

#### LLM Provider Support
- **OpenAI**: GPT-4, GPT-4 Turbo, GPT-3.5 Turbo
- **Anthropic**: Claude-3 Opus, Claude-3.5 Sonnet, Claude-3 Haiku
- **Azure OpenAI**: Template configuration ready
- **Ollama (Local)**: Mistral model (no external API calls)

#### Access Control
- **Admin Role**: Full system access (admin@deeprunner.ai)
- **DevOps Role**: Monitoring, logs, testing (devops@deeprunner.ai)
- **Team Member Role**: API usage, personal analytics (*@deeprunner.ai)

### Architecture Decisions
- **Deployment**: Manual DigitalOcean droplet (vs managed services)
  - Rationale: Cost-effective ($84/month), full control, easy migration

- **Database**: PostgreSQL with volume persistence
  - Rationale: Reliable, SQL-based logging, easy backups

- **Local LLM**: Ollama with Mistral
  - Rationale: Privacy for sensitive workloads, no external API costs

- **Reverse Proxy**: Nginx
  - Rationale: Battle-tested, efficient, flexible configuration

- **Authentication**: Microsoft 365 OAuth
  - Rationale: Organization already uses M365, SSO simplifies access

### Infrastructure Specifications
- **Recommended Droplet**: CPU-Optimized 4vCPU / 8GB RAM / 100GB SSD
- **Estimated Cost**: ~$84/month (DigitalOcean)
- **Capacity**: 5-50 concurrent users
- **Scaling Path**: Multi-droplet → Kubernetes (documented)

### Known Limitations
- Single droplet (no high availability yet)
- Manual SSL renewal setup (cron-based)
- Dashboard uses mock data (needs LiteLLM API integration)
- No monitoring/alerting (Prometheus/Grafana planned)
- No Redis caching layer (optional optimization)

### Dependencies
- Docker Engine 20.10+
- Docker Compose 2.0+
- OpenSSL (for key generation)
- Certbot (for Let's Encrypt SSL)

---

## Version History

- **[0.1.0]** - Initial project setup and configuration (current)
- **[Unreleased]** - Future enhancements and features

---

**Changelog Maintenance Notes:**
- Update this file for every significant change
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Group changes by type: Added, Changed, Deprecated, Removed, Fixed, Security
- Include rationale for major decisions
- Link to relevant docs/issues where applicable
