# LiteLLM Kubernetes Deployment

This guide provides instructions for deploying the [Official LiteLLM Helm Chart](https://github.com/BerriAI/litellm/tree/main/deploy/charts/litellm-helm) to a Kubernetes cluster.

## Overview

This repository provides a Kubernetes deployment for LiteLLM with:

- **Models**: Pre-configured in `values.litellm.yaml` with wildcard support
- **Database**: PostgreSQL connection (configurable)
- **Secrets**: Provider API keys and database credentials
- **Best for**: Production-ready deployments with flexible model access

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- kubectl configured for your cluster
- Provider API keys for the providers you plan to use
- PostgreSQL database instance (if using existing database connection)

## Quick Start

### Step 1: Create Namespace
```bash
kubectl create namespace litellm
```

### Step 2: Create Provider Secrets
```bash
kubectl create secret generic litellm-provider-keys -n litellm \
  --from-literal=ANTHROPIC_API_KEY="sk-ant-your-key" \
  --from-literal=OPENAI_API_KEY="sk-your-key" \
  --from-literal=GOOGLE_API_KEY="your-key" \
  --from-literal=XAI_API_KEY="your-xai-key"
```

**Note**: Only include API keys for providers you plan to use. 

### Step 3: Create Database Secret
```bash
kubectl create secret generic postgres-credentials -n litellm \
  --from-literal=username="your-db-username" \
  --from-literal=password="your-db-password"
```

**Note**: This step is required only when using an existing database connection (`db.useExisting: true` in `values.litellm.yaml`). The current configuration connects to PostgreSQL at `postgresql.postgresql.svc.cluster.local`. Ensure your PostgreSQL instance is running with a `litellm` database created.

**Alternative**: To use a bundled PostgreSQL instance instead, modify `values.litellm.yaml`:
- Set `db.deployStandalone: true`
- Set `db.useExisting: false`
- Skip this step (no database secret needed)

### Step 4: Deploy LiteLLM
```bash
helm upgrade --install -n litellm litellm oci://ghcr.io/berriai/litellm-helm -f values.litellm.yaml

# Deploy NodePort service for external access
kubectl apply -f nodeport.litellm.yaml -n litellm
```

### Step 5: Access Your Deployment

1. **Get the Master Key**:
   ```bash
   kubectl get secret litellm-masterkey -n litellm -o jsonpath='{.data.masterkey}' | base64 -d
   ```

2. **Access the Dashboard**: http://localhost:30400/ui/

3. **Log In**: Use the master key from step 1

4. **Generate API Key**:
   - Create a new user in the dashboard (recommended for security)
   - Generate an API key for the new user
   - Use this API key for Claude Code instead of the master key

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
/model gemini/gemini-2.0-pro
/model xai/grok-beta
```

**At startup**: Use the `--model` flag
```bash
claude --model <model-id>
```

## Network Access

**Development**: This setup uses NodePort service on port 30400 for local access.

**Production**: For production deployments:
- Enable ingress in `values.litellm.yaml`
- Configure proper TLS certificates
- Remove or skip `nodeport.litellm.yaml`

## Configuration

### Current Setup
- **Models**: Pre-configured with wildcard patterns in `values.litellm.yaml`
- **Providers**: Anthropic, Google, OpenAI, xAI (OpenRouter commented out)
- **Database**: PostgreSQL connection to existing instance
- **Secrets**:
  - `litellm-provider-keys`: API keys for model providers
  - `postgres-credentials`: Database username and password
- **Scaling**: Single replica with optional auto-scaling

### Supported Models
- `claude-*` and `anthropic/*` (Anthropic)
- `gemini/*` (Google)
- `openai/*` (OpenAI)
- `xai/*` (xAI)
- `openrouter/*` (uncomment in `values.litellm.yaml` to enable)

## Open WebUI Integration

Open WebUI provides a ChatGPT-like interface that works seamlessly with LiteLLM. Deploy both components for a complete AI chat solution.

### Quick Deploy Open WebUI

```bash
# Add helm repo
helm repo add open-webui https://helm.openwebui.com/
helm repo update

# Deploy Open WebUI
helm upgrade --install open-webui open-webui/open-webui -n open-webui -f values.open-webui.yaml

# Create NodePort service for external access
kubectl apply -f nodeport.open-webui.yaml

# Access at http://192.168.1.10:30401
```

### Open WebUI Configuration

Open WebUI is pre-configured to use LiteLLM proxy at `http://litellm.litellm.svc:4000/v1` for OpenAI API compatibility.

**Files**:
- `values.open-webui.yaml` - Helm chart configuration
- `nodeport.open-webui.yaml` - NodePort service for external access

## Additional Resources

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [Proxy Configuration Guide](https://docs.litellm.ai/docs/proxy/configs)
- [Official Helm Chart Repository](https://github.com/BerriAI/litellm/tree/main/deploy/charts/litellm-helm)
- [Model Provider Documentation](https://docs.litellm.ai/docs/providers)
- [Open WebUI Helm Charts](https://github.com/open-webui/helm-charts/tree/main/charts/open-webui)