# Jenkins on Kubernetes

Automated Jenkins deployment on Kubernetes with:
- Dynamic Kubernetes agent provisioning
- Configuration as Code (JCasC)
- Pre-installed plugins
- Persistent storage

## Prerequisites

- Kubernetes cluster (Docker Desktop, Minikube, or any K8s cluster)
- kubectl configured
- For Windows: PowerShell
- For Linux/Mac: bash

## Quick Start

### Windows (PowerShell)
```powershell
git clone <your-repo-url>
cd jenkins-k8s
.\deploy.ps1
```

### Linux/Mac
```bash
git clone <your-repo-url>
cd jenkins-k8s
chmod +x deploy.sh
./deploy.sh
```

## Access Jenkins

- **URL**: http://localhost:32000
- **Username**: admin
- **Password**: admin123

## What's Deployed

- Jenkins master in `devops-tools` namespace
- Persistent volume for Jenkins data
- Service with NodePort (32000 for UI, 50000 for agents)
- Pre-configured Kubernetes cloud with agent template
- Auto-installed plugins: kubernetes, workflow-aggregator, git, configuration-as-code

## Test the Setup

1. Login to Jenkins
2. Create a new Pipeline job
3. Use this test script:
```groovy
pipeline {
    agent {
        label 'jenkins-agent'
    }
    stages {
        stage('Test') {
            steps {
                echo 'Running on Kubernetes agent!'
                sh 'hostname'
            }
        }
    }
}
```

4. Run the build and watch pods: `kubectl get pods -n devops-tools -w`

## Cleanup

### Windows
```powershell
.\cleanup.ps1
```

### Linux/Mac
```bash
./cleanup.sh
```

## Customization

### Change Admin Password
Edit `manifests/04-configmaps.yaml` and update the password in `jenkins-casc-config`.

### Add More Plugins
Edit `manifests/04-configmaps.yaml` and add plugins to the `jenkins-plugins` ConfigMap.

### Change Storage Location (Windows)
Edit `manifests/03-volume.yaml` and modify the `hostPath.path` value.

### Adjust Resources
Edit `manifests/05-jenkins.yaml` to change CPU/memory limits.

## Architecture
```
┌─────────────────┐
│  Jenkins Master │
│   (Pod)         │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Service │ :8080 (UI), :50000 (JNLP)
    └─────────┘
         │
    ┌────┴──────────┐
    │ Kubernetes    │
    │ Cloud Plugin  │
    └───────┬───────┘
            │
    ┌───────┴────────┐
    │ Dynamic Agents │ (Pods created on-demand)
    └────────────────┘
```

## Troubleshooting

### Pods not starting
```bash
kubectl get pods -n devops-tools
kubectl describe pod <pod-name> -n devops-tools
kubectl logs <pod-name> -n devops-tools
```

### Storage issues
Check the path exists and has proper permissions:
- Windows: `C:\jenkins-data`
- Linux/Mac: `/mnt/jenkins-data`

### Agent connection issues
Ensure port 50000 is exposed in the service and not blocked by firewall.

## License

MIT