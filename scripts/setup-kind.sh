#!/bin/bash
set -e

echo "🚀 Setting up Kind cluster for CI/CD testing..."

# Create kind cluster
kind create cluster --name cicd-demo --image kindest/node:v1.30.13 --config kind-config.yaml

echo "✅ Kind cluster created successfully!"

# Verify cluster
kubectl cluster-info --context kind-cicd-demo
kubectl get nodes

echo "🎉 Setup complete! You can now test deployments locally."