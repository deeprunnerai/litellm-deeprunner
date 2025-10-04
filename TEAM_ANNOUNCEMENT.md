# 🚀 Introducing LiteLLM for DeepRunner.ai

**From:** Gaurav
**Date:** October 4, 2025
**Subject:** Your Unified LLM Gateway - Access GPT-4, Claude, Mistral & More!

---

## What We've Built

I'm excited to announce that **DeepRunner.ai now has its own self-hosted LiteLLM proxy**! This gives our entire team unified access to multiple AI models through a single API.

### 🎯 What This Means for You

**One API, Many Models:**
- GPT-4, GPT-4 Turbo, GPT-3.5 (OpenAI)
- Claude-3 Opus, Claude-3.5 Sonnet, Claude-3 Haiku (Anthropic)
- Mistral (Local, private, FREE)
- Easy to add more models as needed

**Your Own API Keys:**
- Create personal API keys through the admin UI
- Track your usage and costs
- No need to manage multiple provider accounts

**Build AI Agents:**
- Use any framework (LangChain, AutoGen, CrewAI, custom)
- All agents can access the same models through one endpoint
- Easy to switch models without code changes

---

## 🖥️ Infrastructure Details

**Deployment:**
- **Server:** DigitalOcean Droplet (Premium AMD 4GB/2CPU)
- **Location:** 46.101.121.227
- **Cost:** $28/month (covers entire team)
- **Access:** https://prod.litellm.deeprunner.ai

**What's Running:**
- LiteLLM Proxy (unified API gateway)
- PostgreSQL (usage tracking & logs)
- Ollama (local open-source models)
- Nginx (SSL, security, routing)
- pgAdmin (database administration)

**Authentication:**
- Microsoft 365 OAuth (use your @deeprunner.ai email)
- Role-based access control
- Secure API key management

---

## 🎨 Screenshots

[**Screenshot 1:** Admin UI Dashboard]
[**Screenshot 2:** API Keys Management]
[**Screenshot 3:** Model Selection]
[**Screenshot 4:** Usage Analytics]

---

## 🤖 Building Agents with LiteLLM

LiteLLM makes it **incredibly easy** to build AI agents that can use multiple models:

### Simple Example (Python)

```python
from openai import OpenAI

# Connect to our LiteLLM endpoint
client = OpenAI(
    base_url="https://prod.litellm.deeprunner.ai/v1",
    api_key="YOUR_LITELLM_KEY"  # Get from admin UI
)

# Use GPT-4 for reasoning
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Analyze this data..."}]
)

# Use local Mistral for privacy-sensitive tasks
response = client.chat.completions.create(
    model="mistral-local",  # FREE, runs on our server
    messages=[{"role": "user", "content": "Summarize this confidential doc"}]
)

# Use Claude for creative writing
response = client.chat.completions.create(
    model="claude-3-sonnet",
    messages=[{"role": "user", "content": "Write a product description"}]
)
```

### Agent Frameworks Supported

**LangChain:**
```python
from langchain.llms import OpenAI

llm = OpenAI(
    openai_api_base="https://prod.litellm.deeprunner.ai/v1",
    openai_api_key="YOUR_LITELLM_KEY",
    model_name="gpt-4"
)
```

**AutoGen, CrewAI, or Custom:**
- Any framework that supports OpenAI SDK
- Just point to our endpoint
- Switch models by changing model name

### Agent Use Cases

**Already Possible:**
- **Research Agents:** GPT-4 for analysis, Claude for summaries
- **Code Agents:** GPT-4 for complex logic, local Mistral for simple tasks
- **Content Agents:** Claude for writing, GPT-4 for editing
- **Multi-Agent Systems:** Different agents using different models
- **Cost-Optimized Agents:** Use local models when possible, cloud when needed

---

## 📝 How to Get Started

### Step 1: Access the Admin UI

Visit: **https://prod.litellm.deeprunner.ai/ui**

1. Click "Sign in with Microsoft"
2. Use your @deeprunner.ai email
3. You'll be redirected back with access

### Step 2: Create Your API Key

1. Navigate to "API Keys" in the left sidebar
2. Click "Create New Key"
3. Give it a name (e.g., "My Project Key")
4. Copy and save the key securely
5. Set optional budget limits

### Step 3: Start Building

```python
pip install openai

# Use in your code
from openai import OpenAI

client = OpenAI(
    base_url="https://prod.litellm.deeprunner.ai/v1",
    api_key="YOUR_KEY_HERE"
)

# That's it! Start building 🚀
```

---

## 💰 Cost & Usage

**Local Models (FREE):**
- `tinyllama` - Runs on our server, $0 per request (for demo only, uses ~600MB RAM)
- `mistral-local` - Runs on our server, $0 per request (requires droplet upsize, request ~4GB RAM)
- Great for: Testing, development, privacy-sensitive data

**Cloud Models (Pay-per-use):**
- GPT-4: ~$0.03 per 1K tokens
- GPT-3.5: ~$0.002 per 1K tokens
- Claude-3-Sonnet: ~$0.015 per 1K tokens

**Budget Controls:**
- Set monthly limits on your API keys
- Track usage in real-time
- Get alerts when approaching limits

**All usage is logged** - you can see:
- Which models you're using
- Total tokens consumed
- Estimated costs
- Request latency

---

## 🎯 Key Advantages

### 1. **Unified Access**
- One API key for all models
- No need to manage multiple provider accounts
- Consistent code across all models

### 2. **Privacy & Control**
- Self-hosted on our infrastructure
- Sensitive data can use local models
- Full audit logs of all requests

### 3. **Cost Visibility**
- Track spending per model
- Use free local models when possible
- Set budgets to control costs

### 4. **Easy Model Switching**
- Test different models without code changes
- A/B test model performance
- Use best model for each task

### 5. **Agent Development**
- Build multi-agent systems easily
- Each agent can use different models
- Easy to prototype and iterate

---

## 🛠️ Advanced Features

**Coming Soon:**
- More Ollama models (Llama3, CodeLlama, Phi3)
- Team usage analytics dashboard
- Slack integration for alerts
- Model performance benchmarks

**Available Now:**
- Database access via pgAdmin
- Full request/response logging
- Role-based permissions
- Microsoft 365 SSO

---

## 📚 Resources

**Documentation:**
- System Design: `docs/SYSTEM_DESIGN.md`
- Deployment Guide: `docs/DEPLOYMENT.md`
- LiteLLM Docs: https://docs.litellm.ai

**Support:**
- Slack: #litellm-support (coming soon)
- Email: gaurav@deeprunner.ai
- GitHub: https://github.com/deeprunnerai/litellm-deeprunner

---

## 🎉 Let's Build Together!

This is **your** LLM infrastructure. I encourage everyone to:

✅ Create your API keys today
✅ Experiment with different models
✅ Build AI agents for your projects
✅ Share your learnings with the team
✅ Suggest new models or features

**Questions?** Drop me a message or post in our team channel!

Looking forward to seeing what you build! 🚀

— Gaurav

---

**Quick Links:**
- **Admin UI:** https://prod.litellm.deeprunner.ai/ui
- **API Endpoint:** https://prod.litellm.deeprunner.ai/v1
- **Database Admin:** https://prod.litellm.deeprunner.ai/pgadmin
- **Repository:** https://github.com/deeprunnerai/litellm-deeprunner
