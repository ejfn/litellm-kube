# LiteLLM Vertex AI Kubernetes Deployment

This repository deploys LiteLLM configured to use Google Cloud Vertex AI models.

## Requirements

- A Kubernetes cluster
- Helm 3.8+ (for OCI support)
- kubectl configured for your cluster
- Google Cloud Application Default Credentials (ADC)

## Quick Start

1. Create a namespace
```bash
kubectl create namespace llm-stack
```

2. Create GCP credentials secret from your local ADC
```bash
kubectl create secret generic gcp-credentials -n llm-stack \
  --from-file=credentials.json=$HOME/.config/gcloud/application_default_credentials.json
```

3. Install with Vertex AI configuration
```bash
helm install my-llm-stack ./llm-stack -n llm-stack -f values.override.yaml
```

4. Get the LiteLLM master key
```bash
kubectl get secret litellm-masterkey -n llm-stack -o jsonpath='{.data.masterkey}' | base64 -d
```

5. Access the LiteLLM UI
- NodePort is enabled on port 30400
- Open http://localhost:30400/ui/

6. Log in and create a user API key
- Log in with the master key from step 4
- Create a user and generate an API key for regular use

## Use with Claude Code

```bash
export ANTHROPIC_BASE_URL="http://localhost:30400"
export ANTHROPIC_AUTH_TOKEN="sk-your-generated-api-key"  # From LiteLLM dashboard
```

### Using Vertex AI models

The deployment is configured to proxy all models through Vertex AI:

```bash
claude --model claude-sonnet-4-5@20250929
claude --model gemini-2.0-flash
```

During a session, switch models using the `/model` slash command.

## Configuration

The deployment uses `values.override.yaml` which configures:

- **Vertex AI Project**: `engineering-miyaai`
- **Vertex AI Location**: `global`
- **Credentials**: Mounted from Kubernetes secret at `/var/run/secrets/gcp/credentials.json`
- **Database**: External PostgreSQL at `postgres-postgresql.postgres.svc.cluster.local`

## Notes

- LiteLLM uses an external PostgreSQL database (see `values.override.yaml`)
- GCP credentials are mounted as a Kubernetes secret volume
- For production, consider using Ingress with TLS instead of NodePort

## References

- LiteLLM docs: https://docs.litellm.ai/
- Vertex AI setup: https://docs.litellm.ai/docs/providers/vertex
- Official LiteLLM Helm chart: https://github.com/BerriAI/litellm/pkgs/container/litellm-helm