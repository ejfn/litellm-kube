# LiteLLM Kubernetes Deployment

## Deploy

```bash
kubectl create namespace litellm

helm upgrade --install -n litellm litellm oci://ghcr.io/berriai/litellm-helm -f values.yaml
```

## Provider API keys (Helm / Kubernetes secret)

Create a Kubernetes secret containing your providers' API keys and give it
the name referenced in `values.yaml` (default: `litellm-provider-keys`).

**Recommended method** (keeps keys out of git):

```bash
kubectl create secret generic litellm-provider-keys -n litellm \
  --from-literal=OPENAI_API_KEY="sk-your-openai-key" \
  --from-literal=ANTHROPIC_API_KEY="sk-ant-your-anthropic-key" \
  --from-literal=GOOGLE_API_KEY="your-google-api-key" \
  --from-literal=OPENROUTER_API_KEY="sk-or-your-openrouter-key"
```

Replace the example keys above with your actual API keys from each provider.

Then ensure `values.yaml` points to that secret via `environmentSecrets` and the model configurations reference them with `os.environ/API_KEY_NAME`.

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
- **Model configuration in values.yaml**
- **Provider API keys in Kubernetes secret** (referenced via `environmentSecrets`)
- **Wildcard model support** (gpt-*, claude-*, gemini-*)

## Post-Deployment Setup

1. **Create provider API keys secret**: Use the kubectl command in the "Provider API keys" section below
2. **Access the LiteLLM Dashboard**: http://litellm.home.arpa  
3. **Login with master key**: Use the auto-generated master key as authentication
4. **Models are pre-configured**: Wildcard entries in values.yaml support all major model variants
5. **Create API Keys**: Generate multiple API keys for different users/applications through the UI

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
