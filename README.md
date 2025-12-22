# Open WebUI Deployment

This repository contains a standalone deployment configuration for Open WebUI on Kubernetes.

## Structure

-   `open-webui/`: Contains the Helm values, update script, and configuration.

## Deployment

To install or update the deployment:

```bash
cd open-webui
./update.sh
```

## Configuration

Configuration values are stored in `open-webui/values.yaml`.
secrets have been migrated to the `open-webui` namespace.

## References

- [Open WebUI Helm Charts](https://github.com/open-webui/helm-charts)