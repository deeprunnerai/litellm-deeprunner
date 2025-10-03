# LiteLLM Deployment - DeepRunner.ai

Production-ready LiteLLM deployment with PostgreSQL, Ollama (Mistral), Nginx reverse proxy, and Microsoft 365 OAuth authentication.

## 🚀 Features

- **Multi-Provider Support**: OpenAI, Anthropic, Azure OpenAI, and local Ollama models
- **Local LLM**: Mistral model running on Ollama (no external API calls)
- **Secure Database**: PostgreSQL with encrypted data persistence
- **SSL/HTTPS**: Nginx reverse proxy with Let's Encrypt support
- **Microsoft 365 SSO**: Azure AD authentication for organization-wide access
- **Role-Based Access**: Admin, DevOps, and Team Member roles
- **Analytics Dashboard**: Custom 1-page dashboard for monitoring usage
- **High Performance**: CPU-optimized for production workloads
- **Auto-Scaling**: Load balancing and request queuing

## 📋 Quick Start

### What You Need

1. **DigitalOcean Droplet** (CPU-Optimized 4vCPU / 8GB RAM)
2. **Domain Name** (e.g., `litellm.deeprunner.ai`)
3. **API Keys** for LLM providers
4. **Microsoft 365 Admin Access** (for OAuth)

### 1. Clone & Configure

```bash
git clone <repo-url>
cd litellm-deeprunner
cp .env.template .env
nano .env  # Add your configuration
```

### 2. Deploy

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

The script will:
- Check prerequisites (Docker, Docker Compose)
- Generate secure keys
- Setup SSL certificates
- Deploy all services
- Download Mistral model
- Run health checks

### 3. Access

- **Admin UI**: `https://litellm.deeprunner.ai/ui`
- **Analytics Dashboard**: `https://litellm.deeprunner.ai/dashboard`
- **API Endpoint**: `https://litellm.deeprunner.ai/v1`

## 🚀 Deployment Status

**Current Deployment**: In Progress
- **Droplet**: 46.101.121.227 (Premium AMD 4GB/2CPU)
- **Status**: Files uploaded, awaiting configuration
- **Optimized**: For 4GB RAM (2 workers, limited Ollama memory)
- **Next**: Domain setup → SSL → Deploy

See [TASKS.md](TASKS.md) for detailed progress tracking.

## 📁 Project Structure

```
litellm-deeprunner/
├── config/
│   ├── litellm-config.yaml    # LiteLLM configuration
│   ├── nginx.conf              # Nginx reverse proxy config
│   └── ssl/                    # SSL certificates
├── dashboard/
│   └── index.html              # Custom analytics dashboard
├── data/
│   ├── postgres/               # PostgreSQL data (persistent)
│   └── ollama/                 # Ollama models (persistent)
├── docs/
│   ├── DEPLOYMENT.md           # Complete deployment guide
│   └── M365_OAUTH_SETUP.md     # Microsoft 365 OAuth setup
├── scripts/
│   └── setup.sh                # Automated deployment script
├── docker-compose.yml          # Service orchestration
├── .env.template               # Environment variables template
└── README.md                   # This file
```

## 🔧 Configuration

### Environment Variables

Key variables in `.env`:

```env
# Database
POSTGRES_PASSWORD=your-secure-password

# LiteLLM
LITELLM_MASTER_KEY=sk-your-master-key
LITELLM_SALT_KEY=your-salt-key
UI_USERNAME=admin
UI_PASSWORD=your-admin-password

# Microsoft 365 OAuth
MICROSOFT_CLIENT_ID=your-client-id
MICROSOFT_CLIENT_SECRET=your-client-secret
MICROSOFT_TENANT_ID=your-tenant-id

# Domain
DOMAIN=litellm.deeprunner.ai

# LLM Provider API Keys
OPENAI_API_KEY=sk-your-openai-key
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key
AZURE_API_KEY=your-azure-key
```

Generate secure keys:
```bash
openssl rand -hex 32
```

### Supported Models

**OpenAI:**
- gpt-4, gpt-4-turbo, gpt-3.5-turbo

**Anthropic:**
- claude-3-opus, claude-3-sonnet, claude-3-haiku

**Local (Ollama):**
- mistral-local

**Azure OpenAI:**
- Configure in `config/litellm-config.yaml`

## 🎯 API Usage

### Using cURL

```bash
curl https://litellm.deeprunner.ai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Using OpenAI Python SDK

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_MASTER_KEY",
    base_url="https://litellm.deeprunner.ai/v1"
)

response = client.chat.completions.create(
    model="claude-3-sonnet",  # Works with any configured model
    messages=[{"role": "user", "content": "Hello from DeepRunner.ai!"}]
)

print(response.choices[0].message.content)
```

### Using Local Mistral Model

```python
response = client.chat.completions.create(
    model="mistral-local",  # No external API calls
    messages=[{"role": "user", "content": "Analyze this code..."}]
)
```

## 🔐 Security Features

- **HTTPS Only**: SSL/TLS encryption via Let's Encrypt
- **Database Encryption**: PostgreSQL data at rest encryption
- **Network Isolation**: Ollama only accessible via LiteLLM
- **Firewall**: UFW with minimal open ports (22, 80, 443)
- **Fail2Ban**: Brute-force protection
- **OAuth**: Microsoft 365 SSO (no password management)
- **RBAC**: Role-based access control
- **Rate Limiting**: API request throttling
- **Audit Logs**: Complete request/response logging

## 📊 Role-Based Access Control

### Admin
- Full system access
- Manage API keys
- Configure models
- View all logs
- System settings

### DevOps
- Monitor performance
- View logs
- Create test API keys
- Access analytics

### Team Members
- Use API keys
- View personal usage
- Access models
- Limited admin functions

## 🛠️ Management Commands

### View Status
```bash
docker ps
docker-compose logs -f
```

### Restart Services
```bash
docker-compose restart
docker-compose restart litellm  # Specific service
```

### Update Services
```bash
docker-compose pull
docker-compose up -d
```

### Backup Database
```bash
docker exec litellm-postgres pg_dump -U litellm_user litellm > backup.sql
```

### View Resource Usage
```bash
docker stats
```

## 📖 Documentation

- **[Deployment Guide](docs/DEPLOYMENT.md)**: Complete setup instructions
- **[M365 OAuth Setup](docs/M365_OAUTH_SETUP.md)**: Azure AD configuration
- **[LiteLLM Docs](https://docs.litellm.ai)**: Official documentation
- **[Ollama Docs](https://ollama.ai/docs)**: Local model management

## 🔄 Maintenance

### Automated Backups
Database backups run daily at 2 AM (configured in setup script).

### SSL Renewal
Let's Encrypt certificates auto-renew on 1st and 15th of each month.

### Updates
```bash
cd ~/litellm-deeprunner
git pull  # If using git
docker-compose pull
docker-compose up -d
```

## 🐛 Troubleshooting

### Service Won't Start
```bash
docker-compose logs <service-name>
docker-compose restart <service-name>
```

### Can't Access Admin UI
1. Check SSL certificate: `openssl x509 -in config/ssl/fullchain.pem -text -noout`
2. Verify DNS: `dig litellm.deeprunner.ai`
3. Check firewall: `sudo ufw status`

### Ollama Model Issues
```bash
docker exec litellm-ollama ollama pull mistral
docker-compose restart ollama
```

### OAuth Login Fails
See [M365_OAUTH_SETUP.md](docs/M365_OAUTH_SETUP.md) troubleshooting section.

## 💰 Cost Estimate

### Infrastructure (DigitalOcean)
- Droplet: $84/month (CPU-Optimized 4vCPU/8GB)
- Bandwidth: Included (1TB)
- Backups: $8.40/month (optional)

### LLM Provider Costs
- OpenAI: Pay-as-you-go
- Anthropic: Pay-as-you-go
- Azure: Pay-as-you-go
- Ollama (Local): Free

**Total Infrastructure**: ~$84-92/month

## 📝 License

MIT License - See LICENSE file for details

## 🤝 Support

For issues or questions:
- Check documentation in `docs/`
- Review logs: `docker-compose logs`
- Contact: admin@deeprunner.ai

## 🙏 Credits

Built with:
- [LiteLLM](https://github.com/BerriAI/litellm) - OpenSource LLM proxy
- [Ollama](https://ollama.ai) - Run LLMs locally
- [PostgreSQL](https://postgresql.org) - Database
- [Nginx](https://nginx.org) - Reverse proxy
- [Docker](https://docker.com) - Containerization

---

**DeepRunner.ai** - Empowering teams with unified LLM access
