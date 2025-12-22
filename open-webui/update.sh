#!/bin/bash
set -e

# Update Open WebUI
# Using remote chart
helm repo add open-webui https://helm.openwebui.com/
helm repo update open-webui

helm upgrade --install open-webui open-webui/open-webui \
  -f values.yaml \
  --create-namespace \
  --namespace open-webui
