# LLM Stack Kubernetes Deployment

This repository ships an umbrella Helm chart that deploys only LiteLLM by default. Open WebUI and Qdrant are optional add‑ons you can enable later.

## Requirements

- A Kubernetes cluster
- Helm 3.8+ (for OCI support)
- kubectl configured for your cluster

## Quick Start (defaults: LiteLLM only)

1. Create a namespace
```bash
kubectl create namespace llm-stack
```

2. Add your provider API keys as a secret (include only the keys you use)
```bash
kubectl create secret generic litellm-provider-keys -n llm-stack \
  --from-literal=ANTHROPIC_API_KEY="sk-ant-your-key" \
  --from-literal=OPENAI_API_KEY="sk-your-key" \
  --from-literal=GOOGLE_API_KEY="your-key" \
  --from-literal=XAI_API_KEY="your-xai-key"
```

3. Install with default values (deploys LiteLLM only)
```bash
helm install my-llm-stack ./llm-stack -n llm-stack
```

4. Get the LiteLLM master key
```bash
kubectl get secret litellm-masterkey -n llm-stack -o jsonpath='{.data.masterkey}' | base64 -d
```

5. Access the LiteLLM UI
- NodePort is enabled by default on port 30400
- Open http://localhost:30400/ui/

6. Log in and create a user API key
- Log in with the master key from step 4
- Create a user and generate an API key for regular use

## Use with Claude Code (example)

```bash
export ANTHROPIC_BASE_URL="http://localhost:30400"
export ANTHROPIC_AUTH_TOKEN="sk-your-generated-api-key"  # From LiteLLM dashboard
```

## Optional: Enable extras (Open WebUI, Qdrant)

1) Create custom-values.yaml with the components you want:
```yaml
# custom-values.yaml
open-webui:
  enabled: true
  nodeport:
    enabled: true
    nodePort: 30401

qdrant:
  enabled: true
  nodeport:
    enabled: true
    nodePort: 30402
```

2) Install with your overrides:
```bash
helm install my-llm-stack ./llm-stack -n llm-stack -f custom-values.yaml
```

## Defaults (values.yaml)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `litellm.enabled` | bool | `true` | Enable LiteLLM |
| `litellm.nodeport.enabled` | bool | `true` | Enable NodePort for LiteLLM |
| `litellm.nodeport.nodePort` | int | `30400` | NodePort for LiteLLM |
| `open-webui.enabled` | bool | `false` | Enable Open WebUI |
| `open-webui.nodeport.enabled` | bool | `false` | Enable NodePort for Open WebUI |
| `open-webui.nodeport.nodePort` | int | `30401` | NodePort for Open WebUI |
| `qdrant.enabled` | bool | `false` | Enable Qdrant |
| `qdrant.nodeport.enabled` | bool | `false` | Enable NodePort for Qdrant |
| `qdrant.nodeport.nodePort` | int | `30402` | NodePort for Qdrant HTTP |

## Notes

- LiteLLM deploys with a bundled PostgreSQL by default; no database setup is required for Quick Start.
- For production, consider using Ingress with TLS and disabling NodePort.

## Chart structure

```
llm-stack/
├── Chart.yaml
├── values.yaml
├── README.md
└── templates/
    ├── litellm-nodeport.yaml
    ├── open-webui-nodeport.yaml
    └── qdrant-nodeport.yaml
```

## References

- LiteLLM docs: https://docs.litellm.ai/
- Proxy config: https://docs.litellm.ai/docs/proxy/configs
- Official LiteLLM Helm chart: https://github.com/BerriAI/litellm/pkgs/container/litellm-helm
- Model providers: https://docs.litellm.ai/docs/providers
- Open WebUI charts: https://github.com/open-webui/helm-charts
- Qdrant charts: https://github.com/qdrant/qdrant-helm