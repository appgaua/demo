#!/usr/bin/env python3
"""
Template rendering script for GitOps Demo
Renders Jinja2 templates with environment-specific configurations
"""

import os
import sys
import yaml
import argparse
from pathlib import Path
from jinja2 import Environment, FileSystemLoader

def load_config(config_file):
    """Load configuration from YAML file"""
    with open(config_file, 'r') as f:
        return yaml.safe_load(f)

def render_templates(config, template_dir, output_dir, environment):
    """Render all templates for given environment"""
    
    # Setup Jinja2 environment
    env = Environment(
        loader=FileSystemLoader(template_dir),
        trim_blocks=True,
        lstrip_blocks=True
    )
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Render K8s templates
    k8s_templates = [
        'deployment.yaml.j2',
        'service.yaml.j2', 
        'namespace.yaml.j2'
    ]
    
    for template_name in k8s_templates:
        template = env.get_template(f'k8s/{template_name}')
        output_file = template_name.replace('.j2', '')
        output_path = os.path.join(output_dir, output_file)
        
        with open(output_path, 'w') as f:
            f.write(template.render(**config))
        
        print(f"✅ Rendered {template_name} → {output_path}")
    
    # Render ArgoCD templates
    argocd_templates = [
        'application.yaml.j2',
        'app-of-apps.yaml.j2'
    ]
    
    for template_name in argocd_templates:
        template = env.get_template(f'argocd/{template_name}')
        output_file = template_name.replace('.j2', '')
        output_path = os.path.join(output_dir, output_file)
        
        with open(output_path, 'w') as f:
            f.write(template.render(**config))
        
        print(f"✅ Rendered {template_name} → {output_path}")

def main():
    parser = argparse.ArgumentParser(description='Render Jinja2 templates')
    parser.add_argument('--environment', '-e', required=True, 
                       choices=['dev', 'prod'], help='Environment to render')
    parser.add_argument('--image-tag', '-t', help='Docker image tag to use')
    parser.add_argument('--version', '-v', help='Application version')
    parser.add_argument('--output-dir', '-o', default='rendered', 
                       help='Output directory for rendered files')
    
    args = parser.parse_args()
    
    # Load configuration
    config_file = f'config/{args.environment}.yaml'
    if not os.path.exists(config_file):
        print(f"❌ Configuration file {config_file} not found")
        sys.exit(1)
    
    config = load_config(config_file)
    
    # Override with command line arguments
    if args.image_tag:
        config['image_tag'] = args.image_tag
    if args.version:
        config['version'] = args.version
    
    # Set output directory based on environment
    output_dir = f"{args.output_dir}/{args.environment}"
    
    print(f"🚀 Rendering templates for {args.environment} environment")
    print(f"📁 Output directory: {output_dir}")
    print(f"🏷️  Image tag: {config['image_tag']}")
    print(f"📦 Version: {config['version']}")
    print()
    
    # Render templates
    try:
        render_templates(config, 'templates', output_dir, args.environment)
        print()
        print(f"🎉 Successfully rendered all templates for {args.environment}")
    except Exception as e:
        print(f"❌ Error rendering templates: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
