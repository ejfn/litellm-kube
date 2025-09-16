# Open WebUI Deployment

## Quick Deploy

```bash
# Add helm repo
helm repo add open-webui https://helm.openwebui.com/
helm repo update

# Deploy Open WebUI
helm upgarde --install open-webui open-webui/open-webui -n open-webui -f values.yaml

# Create NodePort service for external access
kubectl apply -f open-webui-nodeport.yaml

# Access at http://192.168.1.10:30401
```

## Files

- `values.yaml` - Helm chart configuration
- `open-webui-nodeport.yaml` - NodePort service for external access

## Configuration

Open WebUI is configured to use LiteLLM proxy at `http://litellm.litellm.svc:4000/v1` for OpenAI API compatibility.

## References

- [Open WebUI Helm Charts](https://github.com/open-webui/helm-charts/tree/main/charts/open-webui)