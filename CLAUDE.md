# Claude AI Assistant Instructions

## Project Overview
LiteLLM deployment for DeepRunner.ai - A production-ready unified LLM proxy with PostgreSQL, Ollama (Mistral), Nginx, and Microsoft 365 OAuth authentication.

## Project Context
- **Organization**: DeepRunner.ai
- **Purpose**: Self-hosted LiteLLM proxy for team access to multiple LLM providers
- **Infrastructure**: DigitalOcean CPU-Optimized droplet (4vCPU/8GB RAM)
- **Tech Stack**: Docker, PostgreSQL, LiteLLM, Ollama, Nginx
- **Authentication**: Microsoft 365 OAuth (Azure AD)

## Key Decisions Made
1. **Deployment Strategy**: Manual droplet (not managed services) for cost-effectiveness and control
2. **Database**: PostgreSQL with volume persistence for secure data storage
3. **Local LLM**: Ollama with Mistral model (no external API for certain workloads)
4. **Reverse Proxy**: Nginx with SSL/TLS and rate limiting
5. **Authentication**: M365 SSO with role-based access (Admin, DevOps, Team Members)
6. **Scaling Path**: Start simple, scale to multi-droplet when needed (50+ users)

## Documentation Standards
- **Keep docs concise**: Focus on actionable information, avoid fluff
- **Update as we progress**: Always update relevant docs when making changes
- **Prune outdated info**: Remove obsolete instructions/configurations
- **No code snippets in docs**: Reference files instead of duplicating code
- **Maintain CHANGELOG.md**: Track all significant changes

## File Organization
```
litellm-deeprunner/
├── config/          # Configuration files (litellm, nginx, ssl)
├── dashboard/       # Custom analytics dashboard
├── data/            # Persistent data (git-ignored)
├── docs/            # Detailed guides
├── scripts/         # Automation scripts
├── CLAUDE.md        # This file - AI assistant instructions
├── TASKS.md         # Current and planned tasks
├── CHANGELOG.md     # Change history
└── README.md        # User-facing documentation
```

## When Working on This Project

### Always:
1. **Update TASKS.md**: Mark tasks complete, add new ones discovered
2. **Update CHANGELOG.md**: Document all significant changes
3. **Keep README.md current**: Reflect latest state of project
4. **Prune outdated docs**: Remove obsolete information from all docs
5. **Use TodoWrite tool**: Break tasks into smaller, manageable pieces
6. **Reference files by path**: Use `file:line` format for code references

### Never:
1. **Don't duplicate code in docs**: Reference config files instead
2. **Don't create unnecessary files**: Prefer editing existing files
3. **Don't add verbose explanations**: Keep it concise and actionable
4. **Don't commit sensitive data**: Ensure .gitignore is comprehensive
5. **Don't create new docs unless required**: Update existing ones first

## Documentation Maintenance Protocol

### When Adding Features:
1. Update relevant config files
2. Update TASKS.md (mark feature as complete, add follow-up tasks)
3. Update CHANGELOG.md with details
4. Update README.md if user-facing
5. Update deployment docs if affects setup
6. Remove outdated information from all affected docs

### When Fixing Bugs:
1. Document fix in CHANGELOG.md
2. Update troubleshooting sections in docs
3. Update TASKS.md (mark bug fix complete)
4. Prune any workarounds that are no longer needed

### When Refactoring:
1. Update all references to changed files/configs
2. Update CHANGELOG.md with rationale
3. Prune deprecated approaches from docs
4. Update TASKS.md with refactoring status

## Current State
- **Phase**: Initial setup complete
- **Status**: Ready for deployment
- **Next Steps**: User needs to provide domain, droplet IP, M365 credentials

## API Providers Configured
- OpenAI (gpt-4, gpt-4-turbo, gpt-3.5-turbo)
- Anthropic (claude-3-opus, claude-3-sonnet, claude-3-haiku)
- Azure OpenAI (template ready, needs configuration)
- Ollama Local (mistral-local)

## Access Control Roles
1. **Admin**: Full system access (admin@deeprunner.ai)
2. **DevOps**: Monitoring, logs, test keys (devops@deeprunner.ai)
3. **Team Members**: API usage, personal analytics (*@deeprunner.ai)

## Security Considerations
- All secrets in .env (never committed)
- PostgreSQL data encrypted at rest
- Ollama only accessible via LiteLLM (no external access)
- HTTPS-only via Nginx with Let's Encrypt
- M365 OAuth for authentication (no password management)
- Rate limiting on API endpoints
- Firewall: Only ports 22, 80, 443 open

## Scaling Strategy
- **Now**: Single droplet (~$84/month for 5-50 users)
- **Phase 2**: Multi-droplet + load balancer (~$250-300/month for 100-500 users)
- **Phase 3**: Kubernetes or managed services (~$500+/month for 1000+ users)

## Monitoring & Maintenance
- Custom analytics dashboard at /dashboard
- LiteLLM admin UI at /ui
- Automated database backups (daily at 2am)
- SSL auto-renewal (1st and 15th of month)
- Docker stats for resource monitoring

## Todo Management
- Break down complex tasks into smaller subtasks
- Use TodoWrite tool to track progress
- Update TASKS.md with current state
- Mark tasks complete immediately when done
- Add new tasks discovered during implementation

## Communication Style
- Be concise and direct
- Avoid unnecessary preamble/postamble
- Focus on actionable information
- Use markdown for formatting
- Reference files with paths and line numbers

## Remember
This is a **production deployment** for a real organization. Prioritize:
1. **Security**: Never compromise on security practices
2. **Reliability**: Test changes before documenting
3. **Maintainability**: Keep configs clean and documented
4. **Cost-effectiveness**: Optimize for current scale, plan for growth
5. **Documentation**: Keep all docs current and pruned
