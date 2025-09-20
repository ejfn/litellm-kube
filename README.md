# LiteLLM Kubernetes Deployment

This guide provides instructions for deploying the [Official LiteLLM Helm Chart](https://github.com/BerriAI/litellm/tree/main/deploy/charts/litellm-helm) to a Kubernetes cluster.

## Deployment Options

LiteLLM supports two deployment configurations:

### Option 1: Database-backed Model Storage (Default)
- **Models**: Stored in PostgreSQL database, managed via UI
- **Secrets needed**: `litellm-salt-key`, `postgres-credentials`
- **Best for**: Production environments where you want to manage models dynamically

### Option 2: File-based Model Configuration
- **Models**: Pre-configured in YAML files
- **Secrets needed**: `litellm-provider-keys` (API keys)
- **Best for**: Static configurations with predefined models

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- kubectl configured for your cluster

**For Database-backed storage (default):**
- PostgreSQL service at `postgresql.postgresql.svc.cluster.local`
- Database `litellm` available
- Kubernetes secret `postgres-credentials` with keys `username` and `password`

## Quick Start (Database-backed)

### Step 1: Create Namespace
```bash
kubectl create namespace litellm
```

### Step 2: Create Salt Key Secret
```bash
kubectl create secret generic litellm-salt-key -n litellm \
  --from-literal=LITELLM_SALT_KEY="sk-1234"
```
**Note**: Replace `sk-1234` with your actual salt key. See [LiteLLM documentation](https://docs.litellm.ai/docs/proxy/prod#8-set-litellm-salt-key).

### Step 3: Deploy LiteLLM
```bash
# Deploy LiteLLM with database-backed configuration
helm upgrade --install -n litellm litellm oci://ghcr.io/berriai/litellm-helm -f values.yaml

# Deploy NodePort service for external access
kubectl apply -f litellm-nodeport.yaml -n litellm
```

### Step 4: Access Your Deployment

1. **Get the Master Key**:
   ```bash
   kubectl get secret litellm-masterkey -n litellm -o jsonpath='{.data.masterkey}' | base64 -d
   ```

2. **Access the Dashboard**: http://localhost:30400/ui/

3. **Log In**: Use the master key from step 1

4. **Manage Models**: Add models and API keys through the web UI

## Alternative: File-based Configuration

If you prefer static model configuration:

### Step 1-2: Create Namespace and Provider Secrets
```bash
kubectl create namespace litellm

# Create provider API keys secret
kubectl create secret generic litellm-provider-keys -n litellm \
  --from-literal=ANTHROPIC_API_KEY="sk-ant-your-key" \
  --from-literal=OPENAI_API_KEY="sk-your-key" \
  --from-literal=GOOGLE_API_KEY="your-key"
```

### Step 3: Deploy with File-based Configuration
```bash
helm upgrade --install -n litellm litellm \
  oci://ghcr.io/berriai/litellm-helm \
  -f values.with-models.yaml
```

**Note**: Only include API keys for providers you plan to use. Ensure your `values.with-models.yaml` references the secret via `environmentSecrets`.

## Using LiteLLM with Claude Code

Configure Claude Code to use your LiteLLM proxy:

```bash
export ANTHROPIC_BASE_URL="http://localhost:30400"
export ANTHROPIC_AUTH_TOKEN="sk-your-generated-api-key"  # From LiteLLM dashboard
```

### Model Selection

**In chat**: Use the `/model` command
```
/model claude-sonnet-4-20250514
/model gemini/gemini-2.5-pro
/model openrouter/x-ai/grok-code-fast-1
```

**At startup**: Use the `--model` flag
```bash
claude --model <model-id>
```

## Network Access

This setup uses NodePort (port 30400) for local development. For production:
- Enable ingress in `values.yaml`
- Remove or don't apply `litellm-nodeport.yaml`

## Configuration Summary

**Database-backed deployment uses:**
- Auto-generated master key (Kubernetes secret)
- PostgreSQL for model storage
- Salt key for encryption
- Dynamic model management via UI

**File-based deployment uses:**
- Static model configuration in YAML
- Provider API keys in Kubernetes secrets
- No database dependency

## Documentation

- [LiteLLM Docs](https://docs.litellm.ai/)
- [LiteLLM Proxy Configuration](https://docs.litellm.ai/docs/proxy/configs)
- [Official LiteLLM Helm Chart](https://github.com/BerriAI/litellm/tree/main/deploy/charts/litellm-helm)