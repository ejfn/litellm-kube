#!/bin/bash

# Update Helm dependencies
helm dependency update ./llm-stack/

# Upgrade the Helm release
helm upgrade -n llm-stack llm-stack ./llm-stack/ -f values.override.yaml

echo "Deployment update completed."