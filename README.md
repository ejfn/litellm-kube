# LiteLLM Kubernetes Deployment

This deployment uses the official [LiteLLM Helm Chart](https://github.com/BerriAI/litellm/tree/main/deploy/charts/litellm-helm) with a NodePort service for external access.

## Deploy

```bash
kubectl create namespace litellm

# Deploy LiteLLM using Helm
helm upgrade --install -n litellm litellm oci://ghcr.io/berriai/litellm-helm -f values.yaml

# Deploy NodePort service for external access on port 30400
kubectl apply -f litellm-nodeport.yaml -n litellm
```

**Note**: This setup uses NodePort for local access. If you prefer ingress (for production or custom domain setup), you can enable ingress in `values.yaml` instead of using the NodePort service.

## Provider API keys (Helm / Kubernetes secret)

Create a Kubernetes secret containing your providers' API keys and give it
the name referenced in `values.yaml` (default: `litellm-provider-keys`).

**Recommended method** (keeps keys out of git):

```bash
kubectl create secret generic litellm-provider-keys -n litellm \
  --from-literal=ANTHROPIC_API_KEY="sk-ant-your-anthropic-key" \
  --from-literal=OPENAI_API_KEY="sk-your-openai-key" \
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

## Configuration

Your setup uses:
- **Auto-generated master key** (stored in Kubernetes secret)
- **Model configuration in values.yaml**
- **Provider API keys in Kubernetes secret** (referenced via `environmentSecrets`)
- **Wildcard model support** (gpt-*, claude-*, gemini-*)

## Post-Deployment Setup

1. **Create provider API keys secret**: Use the kubectl command in the "Provider API keys" section below
2. **Access the LiteLLM Dashboard**: http://localhost:30400/ui/
3. **Login with master key**: Use the auto-generated master key as authentication
4. **Models are pre-configured**: Wildcard entries in values.yaml support all major model variants
5. **Create API Keys**: Generate multiple API keys for different users/applications through the UI

## Use with Claude Code

Set environment variables to use LiteLLM as Anthropic proxy:

```bash
export ANTHROPIC_BASE_URL="http://localhost:30400"
# Use an API key created through the LiteLLM dashboard (not the master key):
export ANTHROPIC_AUTH_TOKEN="sk-your-generated-api-key"
```

Then Claude Code will automatically route Anthropic requests through your LiteLLM proxy.

### Select the model

- Use the slash command inside a chat session:

```
/model claude-3-5-sonnet-20241022               # Uses claude-* wildcard pattern
/model gpt-4o                                   # Uses gpt-* wildcard pattern  
/model gemini-2.0-flash-exp                     # Uses gemini-* wildcard pattern
/model openrouter/x-ai/grok-beta                # Uses openrouter/* wildcard for OpenRouter
/model openrouter/deepseek/deepseek-r1          # Uses openrouter/* wildcard for OpenRouter
```

- Alternatively, start Claude Code with a model flag `claude --model <model-id>`

**Note**: The wildcard patterns (`claude-*`, `gpt-*`, `gemini-*`, and `"*"` for OpenRouter models) allow access to any model from these providers without needing to pre-configure each specific model.



## Documentation

- [LiteLLM Docs](https://docs.litellm.ai/)
- [LiteLLM Proxy Configuration](https://docs.litellm.ai/docs/proxy/configs)
- [Official LiteLLM Helm Chart](https://github.com/BerriAI/litellm/tree/main/deploy/charts/litellm-helm)
