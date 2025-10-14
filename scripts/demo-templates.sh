#!/bin/bash

set -e

echo "🎨 GitOps Template Rendering Demo"

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
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 is not installed"
        exit 1
    fi
    
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is not installed"
        exit 1
    fi
    
    print_status "Prerequisites OK ✅"
}

# Install Python dependencies
install_dependencies() {
    print_status "Installing Python dependencies..."
    pip3 install -r requirements.txt
    print_status "Dependencies installed ✅"
}

# Demo template rendering
demo_rendering() {
    print_status "Demonstrating template rendering..."
    
    # Clean previous renders
    rm -rf rendered/
    
    # Render DEV templates
    print_info "Rendering DEV environment templates..."
    python3 scripts/render-templates.py \
        --environment dev \
        --image-tag "dev-$(date +%Y%m%d-%H%M%S)" \
        --version "v1.0.0-dev"
    
    # Render PROD templates
    print_info "Rendering PROD environment templates..."
    python3 scripts/render-templates.py \
        --environment prod \
        --image-tag "prod-$(date +%Y%m%d-%H%M%S)" \
        --version "v1.0.0"
    
    print_status "Template rendering complete ✅"
}

# Show rendered files
show_rendered_files() {
    print_status "Rendered files:"
    echo ""
    
    if [ -d "rendered/dev" ]; then
        print_info "DEV environment:"
        ls -la rendered/dev/
        echo ""
    fi
    
    if [ -d "rendered/prod" ]; then
        print_info "PROD environment:"
        ls -la rendered/prod/
        echo ""
    fi
}

# Show differences
show_differences() {
    print_status "Key differences between environments:"
    echo ""
    
    if [ -f "rendered/dev/deployment.yaml" ] && [ -f "rendered/prod/deployment.yaml" ]; then
        print_info "Replicas:"
        echo "DEV:  $(grep 'replicas:' rendered/dev/deployment.yaml)"
        echo "PROD: $(grep 'replicas:' rendered/prod/deployment.yaml)"
        echo ""
        
        print_info "Service Type:"
        echo "DEV:  $(grep 'type:' rendered/dev/service.yaml)"
        echo "PROD: $(grep 'type:' rendered/prod/service.yaml)"
        echo ""
        
        print_info "Image Tags:"
        echo "DEV:  $(grep 'image:' rendered/dev/deployment.yaml)"
        echo "PROD: $(grep 'image:' rendered/prod/deployment.yaml)"
        echo ""
    fi
}

# Test template validation
validate_templates() {
    print_status "Validating rendered templates..."
    
    # Check if kubectl is available
    if command -v kubectl &> /dev/null; then
        print_info "Validating with kubectl..."
        
        for env in dev prod; do
            if [ -d "rendered/$env" ]; then
                print_info "Validating $env environment..."
                kubectl apply --dry-run=client -f rendered/$env/ || print_warning "Validation failed for $env"
            fi
        done
    else
        print_warning "kubectl not found, skipping validation"
    fi
}

# Show usage examples
show_usage_examples() {
    print_status "Usage examples:"
    echo ""
    echo "1. Render specific environment:"
    echo "   python3 scripts/render-templates.py --environment dev --image-tag v1.2.3"
    echo ""
    echo "2. Render with custom version:"
    echo "   python3 scripts/render-templates.py --environment prod --version v2.0.0"
    echo ""
    echo "3. Render all environments:"
    echo "   python3 scripts/render-templates.py --environment dev --image-tag latest"
    echo "   python3 scripts/render-templates.py --environment prod --image-tag latest"
    echo ""
    echo "4. GitHub Actions will automatically:"
    echo "   - Render templates on push"
    echo "   - Create PR with rendered manifests"
    echo "   - Update image tags automatically"
}

# Main execution
main() {
    echo "=========================================="
    echo "🎨 Template Rendering Demo"
    echo "=========================================="
    
    check_prerequisites
    install_dependencies
    demo_rendering
    show_rendered_files
    show_differences
    validate_templates
    show_usage_examples
    
    echo ""
    echo "=========================================="
    print_status "🎉 Template Demo Complete!"
    echo "=========================================="
    
    print_info "Next steps:"
    echo "1. Review rendered files in rendered/ directory"
    echo "2. Commit templates and configs to trigger GitHub Actions"
    echo "3. Watch automatic PR creation with rendered manifests"
    echo "4. Merge PR to deploy changes via ArgoCD"
}

# Run main function
main "$@"
