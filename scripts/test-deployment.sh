#!/bin/bash
set -e

APP_TYPE=${1:-"both"}  # custom, standard, or both
CLUSTER_NAME="cicd-demo"

echo "🧪 Testing deployments locally with Kind..."

# Check if kind cluster exists
if ! kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "❌ Kind cluster '$CLUSTER_NAME' not found. Run setup-kind.sh first."
    exit 1
fi

# Set kubectl context
kubectl config use-context "kind-$CLUSTER_NAME"

test_custom_app() {
    echo "📦 Testing Custom App (Hello World API)..."
    
    # Build and load Docker image
    cd apps/hello-world-api
    echo "Building Docker image..."
    docker build -t hello-world-api:latest .
    
    echo "Loading image to Kind cluster..."
    kind load docker-image hello-world-api:latest --name "$CLUSTER_NAME"
    cd ../..
    
    # Deploy using kustomize
    echo "Deploying Hello World API..."
    cd deployments/custom-apps/hello-world-api
    kubectl apply -k .
    
    # Wait for deployment
    echo "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/hello-world-api -n hello-world-api
    
    # Test the deployment
    echo "Testing the deployment..."
    kubectl port-forward -n hello-world-api service/hello-world-api-service 8080:80 &
    PORT_FORWARD_PID=$!
    sleep 5
    
    # Test API endpoints
    if curl -s http://localhost:8080/api/HelloWorld | grep -q "Hello World"; then
        echo "✅ Hello World API is responding correctly!"
    else
        echo "❌ Hello World API test failed!"
        kill $PORT_FORWARD_PID 2>/dev/null || true
        exit 1
    fi
    
    if curl -s http://localhost:8080/api/HelloWorld/health | grep -q "Healthy"; then
        echo "✅ Health check is working!"
    else
        echo "❌ Health check failed!"
        kill $PORT_FORWARD_PID 2>/dev/null || true
        exit 1
    fi
    
    kill $PORT_FORWARD_PID 2>/dev/null || true
    cd ../../..
    
    echo "✅ Custom app deployment test completed successfully!"
}

test_standard_app() {
    echo "🌐 Testing Standard App (Nginx)..."
    
    # Deploy using kustomize
    echo "Deploying Nginx..."
    cd deployments/standard-apps/nginx
    kubectl apply -k .
    
    # Wait for deployment
    echo "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/nginx-demo -n nginx-demo
    
    # Test the deployment
    echo "Testing the deployment..."
    kubectl port-forward -n nginx-demo service/nginx-service 8081:80 &
    PORT_FORWARD_PID=$!
    sleep 5
    
    # Test nginx endpoints
    if curl -s http://localhost:8081/ | grep -q "Nginx CI/CD Demo"; then
        echo "✅ Nginx is serving the custom page correctly!"
    else
        echo "❌ Nginx test failed!"
        kill $PORT_FORWARD_PID 2>/dev/null || true
        exit 1
    fi
    
    if curl -s http://localhost:8081/health | grep -q "healthy"; then
        echo "✅ Nginx health check is working!"
    else
        echo "❌ Nginx health check failed!"
        kill $PORT_FORWARD_PID 2>/dev/null || true
        exit 1
    fi
    
    kill $PORT_FORWARD_PID 2>/dev/null || true
    cd ../../..
    
    echo "✅ Standard app deployment test completed successfully!"
}

show_status() {
    echo "📊 Deployment Status:"
    echo "=== Hello World API ==="
    kubectl get all -n hello-world-api 2>/dev/null || echo "Not deployed"
    echo ""
    echo "=== Nginx Demo ==="
    kubectl get all -n nginx-demo 2>/dev/null || echo "Not deployed"
    echo ""
}

# Main execution
case $APP_TYPE in
    "custom")
        test_custom_app
        ;;
    "standard")
        test_standard_app
        ;;
    "both")
        test_custom_app
        echo ""
        test_standard_app
        ;;
    *)
        echo "Usage: $0 [custom|standard|both]"
        exit 1
        ;;
esac

show_status
echo "🎉 All tests completed successfully!"