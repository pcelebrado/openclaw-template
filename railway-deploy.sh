#!/bin/bash
# Railway CLI Deployment Helper for OpenClaw
# Usage: ./railway-deploy.sh [web|core|all]

set -e

SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo "Usage: ./railway-deploy.sh [web|core|all]"
    echo ""
    echo "Examples:"
    echo "  ./railway-deploy.sh web    # Deploy web service only"
    echo "  ./railway-deploy.sh core   # Deploy core service only"
    echo "  ./railway-deploy.sh all    # Deploy both services"
    exit 1
fi

deploy_service() {
    local service=$1
    local service_path="services/$service"
    
    echo "======================================"
    echo "Deploying $service from $service_path"
    echo "======================================"
    
    cd "$service_path"
    
    # Check if railpack.json exists - use Railpack
    if [ -f "railpack.json" ]; then
        echo "Using Railpack build..."
        railway up --service "$service"
    else
        echo "Using Dockerfile build..."
        railway up --service "$service"
    fi
    
    cd ../..
}

case $SERVICE in
    web)
        deploy_service "web"
        ;;
    core)
        deploy_service "core"
        ;;
    all)
        deploy_service "core"
        deploy_service "web"
        ;;
    *)
        echo "Unknown service: $SERVICE"
        echo "Use: web, core, or all"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo "Deployment complete!"
echo "======================================"
