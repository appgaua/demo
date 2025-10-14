#!/bin/bash

set -e

echo "🚀 GitOps Demo Setup Script"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi
    
    # Check if node is installed
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        exit 1
    fi
    
    # Check if docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    print_status "All prerequisites OK ✅"
}

# Setup local development
setup_local() {
    print_status "Setting up local development environment..."
    
    # Install Node.js dependencies
    npm install
    
    # Install Python dependencies
    print_info "Installing Python dependencies..."
    pip install -r requirements.txt
    
    # Run tests
    print_info "Running tests..."
    npm test
    
    # Run linter
    print_info "Running linter..."
    npm run lint
    
    # Test template rendering
    print_info "Testing template rendering..."
    python scripts/render-templates.py --environment dev --image-tag test
    python scripts/render-templates.py --environment prod --image-tag test
    
    print_status "Local setup complete ✅"
}

# Build Docker image
build_image() {
    print_status "Building Docker image..."
    
    # Build image
    docker build -t gitops-demo-app:latest .
    
    # Test image
    print_info "Testing Docker image..."
    docker run --rm -d -p 3000:3000 --name gitops-demo-test gitops-demo-app:latest
    
    # Wait for container to start
    sleep 5
    
    # Test health endpoint
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        print_status "Docker image test successful ✅"
    else
        print_error "Docker image test failed"
        exit 1
    fi
    
    # Cleanup
    docker stop gitops-demo-test
}

# Deploy to Kubernetes (local)
deploy_local() {
    print_status "Deploying to local Kubernetes..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        print_warning "kubectl not found, skipping Kubernetes deployment"
        return
    fi
    
    # Apply manifests
    kubectl apply -f k8s/prod/
    
    print_status "Local Kubernetes deployment complete ✅"
}

# Show demo instructions
show_demo_instructions() {
    echo ""
    echo "=========================================="
    print_status "🎉 Demo Setup Complete!"
    echo "=========================================="
    
    print_info "Next steps for the demo:"
    echo ""
    echo "1. 📝 Push code to GitHub repository"
    echo "2. 🔄 GitHub Actions will automatically:"
    echo "   • Run tests and linting"
    echo "   • Build and push Docker image"
    echo "   • Update Kubernetes manifests"
    echo "3. 🚀 ArgoCD will automatically:"
    echo "   • Detect changes in the repository"
    echo "   • Sync and deploy to Kubernetes cluster"
    echo ""
    print_info "Demo commands:"
    echo "• Test locally: npm start"
    echo "• Run tests: npm test"
    echo "• Build image: docker build -t gitops-demo-app ."
    echo "• Deploy to K8s: kubectl apply -f k8s/prod/"
    echo ""
    print_info "GitHub Actions workflows:"
    echo "• CI: .github/workflows/ci.yml"
    echo "• CD: .github/workflows/cd.yml"
    echo ""
    print_info "ArgoCD Application:"
    echo "• File: argocd/prod-app.yaml"
    echo "• Apply: kubectl apply -f argocd/prod-app.yaml"
}

# Main execution
main() {
    echo "=========================================="
    echo "🔧 GitOps Demo Setup"
    echo "=========================================="
    
    check_prerequisites
    setup_local
    build_image
    deploy_local
    show_demo_instructions
}

# Run main function
main "$@"
