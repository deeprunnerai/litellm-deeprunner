# LiteLLM Scaling Guide

## Current Deployment Strategy

### Phase 1: Entry-Level Testing (Current)
**Droplet**: Premium AMD $28/mo
- 4 GB RAM / 2 AMD CPUs
- 80 GB NVMe SSD
- 4 TB transfer

**Expected Capacity**:
- Light testing/development workload
- 5-10 concurrent users
- Smaller model inference (Mistral via Ollama may be slow)
- **Monitor closely for OOM (Out of Memory) issues**

**When to Upgrade**:
- Memory usage consistently > 85%
- Ollama responses are slow (>5s)
- PostgreSQL performance degrades
- Frequent OOM errors in logs

---

## Upgrade Path

### Phase 2: Production Ready - $84/mo ⭐ RECOMMENDED
**Droplet**: Premium AMD CPU-Optimized
- 16 GB RAM / 4 AMD CPUs
- 200 GB NVMe SSD
- 8 TB transfer

**Capacity**:
- 50-100 concurrent users
- Fast Ollama inference
- Comfortable headroom for traffic spikes
- Stable PostgreSQL performance

**Upgrade Process**:
1. Take snapshot of current droplet ($0.05/GB/month)
2. Create new $84 droplet from snapshot
3. Update DNS to point to new IP
4. Test thoroughly
5. Destroy old droplet

**Time**: ~15 minutes, minimal downtime

---

### Phase 3: High Availability - $250-300/mo
**Architecture**:
- DigitalOcean Load Balancer ($12/mo)
- 2-3 LiteLLM nodes ($84 each)
- Managed PostgreSQL ($15/mo)
- Separate Ollama droplet ($48/mo)

**Capacity**:
- 200-500 concurrent users
- Zero downtime deployments
- Database failover
- Geographic redundancy

**Setup Time**: 1-2 hours

---

### Phase 4: Enterprise Scale - $500+/mo
**Architecture**:
- Kubernetes (DOKS) or App Platform
- Auto-scaling LiteLLM pods
- Multi-region deployment
- Managed services (DB, Redis, etc.)

**Capacity**:
- 1000+ concurrent users
- Global availability
- Advanced monitoring

---

## Monitoring Resource Usage

### Check Memory Usage
```bash
# On droplet
free -h
```

**Warning Signs**:
- Available memory < 500MB
- Swap usage > 0 (means RAM is full)

### Check CPU Usage
```bash
top
# Press 'q' to quit
```

**Warning Signs**:
- Load average > 2.0 (for 2 CPU droplet)
- Constant 100% CPU usage

### Check Disk Usage
```bash
df -h
```

**Warning Signs**:
- Disk > 80% full

### Docker Stats
```bash
docker stats
```

**Watch For**:
- litellm-ollama using > 2GB RAM consistently
- Any container using > 90% CPU

---

## Upgrade Decision Matrix

| Metric | Stay on $28 | Upgrade to $84 | Scale to Multi-Droplet |
|--------|-------------|----------------|------------------------|
| **Users** | < 10 | 10-50 | > 50 |
| **Memory** | < 70% | > 85% | Maxed out |
| **CPU** | < 50% avg | > 70% avg | Maxed out |
| **Response Time** | < 2s | > 3s | > 5s |
| **Errors** | None | Occasional OOM | Frequent |

---

## Cost Comparison

### Monthly Costs

| Configuration | Cost/Month | Users Supported | Notes |
|---------------|------------|-----------------|-------|
| Entry ($28) | $28 | 5-10 | Testing only |
| Standard ($84) | $84 | 50-100 | Production ready ⭐ |
| HA Setup | $250-300 | 200-500 | High availability |
| Enterprise (K8s) | $500+ | 1000+ | Auto-scaling |

### Cost Per User

- **$28 plan**: ~$2.80/user (10 users)
- **$84 plan**: ~$1.68/user (50 users)
- **HA Setup**: ~$1.00/user (250 users)
- **Enterprise**: ~$0.50/user (1000 users)

*Economics improve with scale*

---

## How to Upgrade from $28 to $84

### Option 1: Snapshot & Restore (Recommended)
```bash
# 1. On current droplet, verify everything works
docker ps

# 2. In DigitalOcean dashboard:
#    - Go to your droplet
#    - Click "Snapshots" tab
#    - Click "Take Snapshot"
#    - Name: litellm-prod-01-YYYYMMDD
#    - Wait ~5 minutes

# 3. Create new droplet from snapshot:
#    - Choose $84/mo plan
#    - Select your snapshot as image
#    - Keep same SSH key
#    - New hostname: litellm-prod-02

# 4. Update DNS to new IP
#    - Point litellm.deeprunner.ai to new IP
#    - Wait for DNS propagation (5-30 min)

# 5. Test new droplet thoroughly

# 6. Destroy old droplet (get refund for unused time)
```

**Downtime**: ~5-30 minutes (DNS propagation)

### Option 2: Resize (Limited)
DigitalOcean allows resizing, but:
- Can only increase disk, not decrease
- May require downtime
- Less flexible than snapshot approach

---

## Optimization Tips for $28 Droplet

To maximize performance on limited resources:

### 1. Reduce Ollama Memory Usage
Edit `docker-compose.yml`:
```yaml
ollama:
  environment:
    - OLLAMA_NUM_PARALLEL=1  # Limit concurrent requests
    - OLLAMA_MAX_LOADED_MODELS=1  # Only keep 1 model in memory
```

### 2. Optimize PostgreSQL
Create `config/postgres.conf`:
```
shared_buffers = 512MB
effective_cache_size = 1GB
work_mem = 8MB
maintenance_work_mem = 64MB
max_connections = 20
```

### 3. Limit LiteLLM Workers
In `docker-compose.yml`:
```yaml
litellm:
  command: --config /app/config.yaml --port 4000 --num_workers 2  # Reduce from 4
```

### 4. Use Smaller Ollama Model
Instead of Mistral, try:
```bash
docker exec litellm-ollama ollama pull phi  # 2.7B params, much smaller
```

Update `config/litellm-config.yaml`:
```yaml
- model_name: phi-local
  litellm_params:
    model: ollama/phi
    api_base: http://ollama:11434
```

---

## Real-Time Monitoring Script

Create `scripts/monitor.sh`:
```bash
#!/bin/bash
while true; do
    clear
    echo "=== LiteLLM Resource Monitor ==="
    echo ""
    echo "Memory Usage:"
    free -h | grep Mem
    echo ""
    echo "CPU Load:"
    uptime
    echo ""
    echo "Docker Stats:"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
    echo ""
    echo "Disk Usage:"
    df -h / | tail -1
    echo ""
    sleep 5
done
```

Run: `./scripts/monitor.sh`

---

## Emergency Actions

### If Memory Runs Out:
```bash
# Quick fix: Restart Ollama (clears model from memory)
docker-compose restart ollama

# Or stop Ollama temporarily
docker-compose stop ollama
```

### If Disk Fills Up:
```bash
# Clean Docker images
docker system prune -a

# Rotate logs
docker-compose logs --tail=1000 > recent-logs.txt
# Then manually clear: /var/lib/docker/containers/*/
```

### If CPU Maxed:
```bash
# Reduce LiteLLM workers
docker-compose down
# Edit docker-compose.yml, reduce num_workers
docker-compose up -d
```

---

## Recommended Timeline

**Week 1**: Deploy on $28, monitor heavily
**Week 2-4**: Optimize, gather usage data
**Month 2**: Decide on upgrade based on:
- Actual user count
- Performance metrics
- Error rates
- Business needs

**Be Ready to Upgrade If**:
- You onboard > 10 active users
- Response times degrade
- Frequent memory warnings in logs

---

**Decision**: Start lean, monitor closely, upgrade confidently when data shows need.

Good engineering is about right-sizing for actual load, not predicted load! 🎯
