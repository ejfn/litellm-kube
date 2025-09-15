# LiteLLM Kubernetes Deployment

This guide provides instructions for deploying the [Official LiteLLM Helm Chart](https://github.com/BerriAI/litellm/tree/main/deploy/charts/litellm-helm) to a Kubernetes cluster, using a NodePort for external access.

## Getting Started

Follow these steps to deploy and configure your LiteLLM instance.

### Step 1: Create Namespace

First, create a dedicated namespace for your LiteLLM resources:

```bash
kubectl create namespace litellm
```

### Step 2: Create Provider API Key Secret

Next, create a Kubernetes secret to securely store your API keys. This method keeps your keys out of version control.

```bash
# Create a secret with the API keys for the providers you plan to use
kubectl create secret generic litellm-provider-keys -n litellm \
  --from-literal=ANTHROPIC_API_KEY="sk-ant-your-anthropic-key" \
  --from-literal=OPENAI_API_KEY="sk-your-openai-key" \
  --from-literal=GOOGLE_API_KEY="your-google-api-key" \
  --from-literal=OPENROUTER_API_KEY="sk-or-your-openrouter-key"
```

**Note**: The command above is an example; only include the `--from-literal` arguments for the providers you plan to use. Ensure your `values.yaml` references this secret via `environmentSecrets` and that your model configurations use `os.environ/API_KEY_NAME`.

### Step 3: Deploy LiteLLM

With the namespace and secret in place, deploy LiteLLM using Helm and your custom `values.yaml`:

```bash
# Deploy LiteLLM using Helm
helm upgrade --install -n litellm litellm oci://ghcr.io/berriai/litellm-helm -f values.yaml

# Deploy the NodePort service for external access on port 30400
kubectl apply -f litellm-nodeport.yaml -n litellm
```

**Note**: This setup uses a NodePort for local access. For production or custom domain setups, consider enabling ingress in `values.yaml` instead of using the NodePort service.

### Step 4: Access Your Deployment

1.  **Get the Master Key**: Retrieve the auto-generated master key, which is required to log in to the dashboard.

    ```bash
    # Get the auto-generated master key and decode it
    kubectl get secret litellm-masterkey -n litellm -o jsonpath='{.data.masterkey}' | base64 -d
    ```

2.  **Access the Dashboard**: Open the LiteLLM UI in your browser.
    - **URL**: http://localhost:30400/ui/

3.  **Log In**: Use the master key obtained in the previous step to log in.

4.  **Manage API Keys**: From the dashboard, you can generate and manage new API keys for different users or applications.

## Using LiteLLM with Claude Code

To use your LiteLLM proxy with Claude Code, configure the following environment variables:

```bash
export ANTHROPIC_BASE_URL="http://localhost:30400"
# Use an API key generated from the LiteLLM dashboard (not the master key)
export ANTHROPIC_AUTH_TOKEN="sk-your-generated-api-key"
```

This configuration will route Claude Code's Anthropic API requests through the LiteLLM proxy.

### Selecting a Model

You can select a model in Claude Code in two ways:

-   **In a chat session**: Use the `/model` slash command.
    ```
    /model claude-sonnet-4-20250514
    /model gemini/gemini-2.5-pro
    /model openrouter/x-ai/grok-code-fast-1
    ```
-   **At startup**: Use the `--model` flag.
    ```bash
    claude --model <model-id>
    ```

## Store models in DB (optional)

To persist the model registry in PostgreSQL, use the provided values file:

```bash
# Use this file alone, or combine with your base values
helm upgrade --install -n litellm litellm \
  oci://ghcr.io/berriai/litellm-helm \
  -f values-store-model-in-db.yaml
```

Prerequisites:
- An existing PostgreSQL service at `postgresql.postgresql.svc.cluster.local`
- Database `litellm` available
- Kubernetes secret `postgres` with keys `username` and `password`

This file sets `STORE_MODEL_IN_DB=true` and configures LiteLLM to use the existing PostgreSQL instance via the secret above.

## Configuration Overview

Your setup uses:
- **Auto-generated master key** (stored in a Kubernetes secret)
- **Model configuration** (defined in `values.yaml`)
- **Provider API keys** (stored in a Kubernetes secret and referenced via `environmentSecrets`)
- **Wildcard model support** (e.g., `openrouter/*`)

## Documentation

- [LiteLLM Docs](https://docs.litellm.ai/)
- [LiteLLM Proxy Configuration](https://docs.litellm.ai/docs/proxy/configs)
- [Official LiteLLM Helm Chart](https://github.com/BerriAI/litellm/tree/main/deploy/charts/litellm-helm)
