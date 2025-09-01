# LiteLLM Kubernetes Deployment

## Deploy

```bash
kubectl create namespace litellm

helm upgrade --install -n litellm litellm oci://ghcr.io/berriai/litellm-helm -f values.yaml
```

## Get Master Key

```bash
# Get the auto-generated master key
kubectl get secret litellm-masterkey -n litellm -o jsonpath='{.data.masterkey}' | base64 -d
```

## Access

```bash
# Via ingress (from any computer on your network)
curl http://litellm.home.arpa/health

# API test (replace sk-9qGOzIoL10AFNiOtAj with your actual master key)
curl http://litellm.home.arpa/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-9qGOzIoL10AFNiOtAj" \
  -d '{"model": "gpt-4", "messages": [{"role": "user", "content": "Hello!"}]}'
```

## Configuration

Your setup uses:
- **Auto-generated master key** (stored in Kubernetes secret)
- **Database storage** for models and API keys (`STORE_MODEL_IN_DB=true`)
- **No model configuration in values.yaml** (all managed via dashboard)
- **No secrets.yaml needed** (API keys managed in database)

## Post-Deployment Setup

1. **Access the LiteLLM Dashboard**: http://litellm.home.arpa
2. **Login with master key**: Use the auto-generated master key as authentication
3. **Add Models**: Configure your LLM providers (OpenAI, Anthropic, Google, etc.) through the UI
4. **Create API Keys**: Generate multiple API keys for different users/applications
5. **Manage Everything**: All configuration is done through the web interface

## Notes

- Ingress uses `litellm.home.arpa` (resolved by home DNS)
- Service runs on ClusterIP with nginx ingress
- For NodePort access, change service type and disable ingress in values.yaml

## Use with Claude Code

Set environment variables to use LiteLLM as Anthropic proxy:

```bash
export ANTHROPIC_BASE_URL="http://litellm.home.arpa"
# Use an API key created through the LiteLLM dashboard (not the master key):
export ANTHROPIC_AUTH_TOKEN="sk-your-generated-api-key"
```

Then Claude Code will automatically route Anthropic requests through your LiteLLM proxy.

**Note**: Create API keys through the LiteLLM UI at http://litellm.home.arpa using the master key for authentication.

## Documentation

- [LiteLLM Docs](https://docs.litellm.ai/)
- [LiteLLM Proxy Configuration](https://docs.litellm.ai/docs/proxy/configs)