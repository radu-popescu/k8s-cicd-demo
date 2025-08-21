#!/bin/bash
set -e

CLUSTER_NAME="cicd-demo"

echo "🧹 Cleaning up CI/CD demo environment..."

# Delete applications
echo "Removing deployed applications..."
kubectl delete namespace hello-world-api --ignore-not-found=true
kubectl delete namespace nginx-demo --ignore-not-found=true

echo "Waiting for cleanup to complete..."
sleep 10

# Delete kind cluster
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "Deleting Kind cluster..."
    kind delete cluster --name "$CLUSTER_NAME"
    echo "✅ Kind cluster deleted!"
else
    echo "Kind cluster '$CLUSTER_NAME' not found."
fi

# Clean up Docker images
echo "Cleaning up Docker images..."
docker rmi hello-world-api:latest 2>/dev/null || true

echo "🎉 Cleanup completed!"