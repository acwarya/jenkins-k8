#!/bin/bash

set -e

echo "🚀 Deploying Jenkins on Kubernetes..."

# Create data directory
echo "📁 Creating Jenkins data directory..."
DATA_DIR="/mnt/jenkins-data"
sudo mkdir -p $DATA_DIR
sudo chmod 777 $DATA_DIR
echo "✓ Created $DATA_DIR"

# Apply manifests in order
echo ""
echo "📦 Applying Kubernetes manifests..."

manifests=(
    "01-namespace.yaml"
    "02-serviceaccount.yaml"
    "03-volume.yaml"
    "04-configmaps.yaml"
    "05-jenkins.yaml"
)

# Update volume path for Linux
sed -i 's|/run/desktop/mnt/host/c/jenkins-data|/mnt/jenkins-data|g' manifests/03-volume.yaml
sed -i 's|docker-desktop|$(kubectl get nodes -o jsonpath="{.items[0].metadata.name}")|g' manifests/03-volume.yaml

for manifest in "${manifests[@]}"; do
    echo "Applying manifests/$manifest..."
    kubectl apply -f "manifests/$manifest"
done

echo ""
echo "✓ All manifests applied successfully!"

# Wait for Jenkins to be ready
echo ""
echo "⏳ Waiting for Jenkins to be ready..."
echo "This may take 2-3 minutes..."

kubectl wait --for=condition=ready pod \
    -l app=jenkins-server \
    -n devops-tools \
    --timeout=300s

echo ""
echo "✓ Jenkins is ready!"
echo ""
echo "🎉 Deployment complete!"
echo ""
echo "📋 Access Information:"
echo "   URL:      http://localhost:32000"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "💡 To watch pods: kubectl get pods -n devops-tools -w"
echo "💡 To view logs:  kubectl logs -n devops-tools -l app=jenkins-server -f"