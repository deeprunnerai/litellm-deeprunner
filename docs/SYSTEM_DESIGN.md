# LiteLLM System Design - DeepRunner.ai

## Architecture Overview

LiteLLM is a **unified proxy** that provides a single OpenAI-compatible API for accessing 100+ LLM providers, including local open-source models via Ollama.

```
┌──────────────────────────────────────────────────────────────────────┐
│                        Client Application                             │
│           (Any OpenAI SDK: Python, JavaScript, cURL)                  │
└─────────────────────────────┬────────────────────────────────────────┘
                              │ HTTPS
                              ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         Nginx (Port 80/443)                           │
│  • SSL/TLS Termination  • Rate Limiting  • Security Headers          │
└──┬───────────────┬───────────────┬──────────────────────────────────┘
   │               │               │
   │ /ui           │ /v1/*         │ /pgadmin
   ▼               ▼               ▼
┌─────────┐  ┌──────────────────────────────┐  ┌──────────────────┐
│ Admin   │  │    LiteLLM Proxy (Port 4000) │  │ pgAdmin          │
│ UI      │  │  • OpenAI-compatible API     │  │ (DB Admin)       │
└─────────┘  │  • Model Routing             │  └──────────────────┘
             │  • Auth & RBAC               │
             │  • Request Logging           │
             └─────────┬────────────────────┘
                       │
        ┌──────────────┼──────────────┬──────────────┐
        │              │              │              │
        ▼              ▼              ▼              ▼
   ┌─────────┐  ┌──────────┐  ┌───────────┐  ┌────────────────┐
   │PostgreSQL│ │ OpenAI   │  │ Anthropic │  │ Ollama (Local) │
   │ • Users  │ │ GPT-4    │  │ Claude-3  │  │ Mistral        │
   │ • Keys   │ │ GPT-3.5  │  │           │  │ Llama3         │
   │ • Logs   │ └──────────┘  └───────────┘  │ (No API costs) │
   │ • Costs  │                               │ (Private)      │
   └─────────┘                                └────────────────┘
```

## How It Works: Request Flow

```
1. Client Request
   POST /v1/chat/completions
   { "model": "mistral-local", "messages": [...] }
          ↓
2. Nginx
   • Validate SSL
   • Check rate limits
   • Route to LiteLLM
          ↓
3. LiteLLM Proxy
   • Authenticate API key (PostgreSQL lookup)
   • Check permissions (RBAC)
   • Identify model: "mistral-local" → Ollama
          ↓
4a. Cloud API Route          4b. Local Model Route
    (GPT-4, Claude)              (Ollama)
    ↓                            ↓
    External API Call            Ollama Container
    • Transform request          • Load model in memory
    • Send to provider           • Run inference on CPU
    • Wait for response          • Return completion
    ↓                            ↓
5. Normalize Response
   • Convert to OpenAI format
   • Calculate tokens & cost
   • Log to PostgreSQL
          ↓
6. Return to Client
   OpenAI-compatible response
```

## Multi-Model Example

**Same code, different models:**

```python
client = OpenAI(base_url="https://litellm.deeprunner.ai/v1", api_key="sk-xxx")

# Cloud API (OpenAI) - costs $0.03/1K tokens
client.chat.completions.create(model="gpt-4", messages=[...])

# Cloud API (Anthropic) - costs $0.015/1K tokens
client.chat.completions.create(model="claude-3-sonnet", messages=[...])

# Local OSS (Ollama) - FREE, private, no external call
client.chat.completions.create(model="mistral-local", messages=[...])
```

**Behind the scenes:**
- `gpt-4` → LiteLLM calls OpenAI API
- `claude-3-sonnet` → LiteLLM calls Anthropic API
- `mistral-local` → LiteLLM calls Ollama container (local, no internet)

## Ollama: Local Open-Source Models

### Why Ollama?
- **Privacy**: Sensitive data never leaves infrastructure
- **Cost**: $0 per request (no API charges)
- **Speed**: Low latency (local inference)
- **Offline**: Works without internet

### Network Isolation

```
Internet  ──X──→  Ollama (blocked, cannot access)
                     ↑
                     │ Internal Docker network only
                     │
LiteLLM   ──✓──→  Ollama (allowed)
```

Ollama runs on an isolated network with **no external access**. Only LiteLLM can communicate with it.

### Available Models

Add any model from [ollama.ai/library](https://ollama.ai/library):

```bash
# Pull model
docker exec litellm-ollama ollama pull llama3

# Add to config/litellm-config.yaml
- model_name: llama3-local
  litellm_params:
    model: ollama/llama3
    api_base: http://ollama:11434

# Restart
docker compose restart litellm
```

**Popular choices:**
- `mistral` (7B) - Fast, general purpose
- `llama3` (8B) - High quality
- `codellama` (7B) - Code generation
- `phi3` (3.8B) - Smaller, faster

## Authentication & Roles

### Microsoft 365 OAuth Flow

```
User → /ui → Redirect to Microsoft → Login → Azure AD returns token
→ LiteLLM creates user in PostgreSQL → Session created → Access granted
```

### Role-Based Access

| Role | Permissions |
|------|------------|
| **Admin** (`proxy_admin`) | Full access: manage keys, configure models, view all logs |
| **DevOps** | Monitor performance, view logs, create test keys |
| **Team Members** | Use API, view personal usage |

Set admin via database:
```sql
UPDATE "LiteLLM_UserTable" SET user_role = 'proxy_admin'
WHERE user_email = 'admin@deeprunner.ai';
```

## Data Persistence

All data stored in **PostgreSQL**:

```
LiteLLM_UserTable
├─ user_id, email, role (OAuth users)

LiteLLM_VerificationToken
├─ API keys (hashed), permissions, expiration

LiteLLM_SpendLogs
├─ model, tokens, cost, latency (every request logged)
```

**Access via pgAdmin:** `http://localhost:8080/pgadmin`

## Resource Usage (4GB RAM Setup)

| Service | Memory | Purpose |
|---------|--------|---------|
| PostgreSQL | ~200MB | Data storage |
| LiteLLM | ~500MB | Proxy server |
| Ollama | ~2GB | Model inference |
| Nginx | ~50MB | Reverse proxy |
| pgAdmin | ~100MB | DB admin |
| **Total** | **~3GB** | (1GB buffer) |

## Key Benefits

1. **One API, Many Models**
   - OpenAI SDK works for GPT-4, Claude, Mistral, etc.
   - Switch models without code changes

2. **Local + Cloud Hybrid**
   - Sensitive data → Ollama (local, private, free)
   - Public data → Cloud APIs (OpenAI, Anthropic)

3. **Cost Tracking**
   - Every request logged with cost
   - Cloud APIs charged per token
   - Local models: $0 per request

4. **Self-Hosted Control**
   - Own your data
   - Custom configurations
   - No vendor lock-in

5. **Enterprise Security**
   - Microsoft 365 OAuth (SSO)
   - Role-based permissions
   - Full audit logs

## Deployment

**Local Dev:**
```bash
docker compose up -d
# Access: http://localhost:3000/ui
```

**Production:**
```bash
./scripts/setup.sh
# Access: https://prod.litellm.deeprunner.ai
```

Both environments run the same stack with identical capabilities.
