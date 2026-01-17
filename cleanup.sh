#!/bin/bash

echo "🧹 Cleaning up Jenkins deployment..."

# Delete Kubernetes resources
echo ""
echo "📦 Deleting Kubernetes resources..."
kubectl delete namespace devops-tools --ignore-not-found=true
kubectl delete storageclass local-storage --ignore-not-found=true
kubectl delete pv jenkins-pv-volume --ignore-not-found=true

echo "✓ Kubernetes resources deleted"

# Ask before deleting data
echo ""
echo "⚠️  Do you want to delete Jenkins data (/mnt/jenkins-data)? [y/N]"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo rm -rf /mnt/jenkins-data
    echo "✓ Deleted /mnt/jenkins-data"
else
    echo "ℹ️  Jenkins data preserved at /mnt/jenkins-data"
fi

echo ""
echo "✓ Cleanup complete!"
```

### `.gitignore`
```
# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log

# Temporary files
*.tmp