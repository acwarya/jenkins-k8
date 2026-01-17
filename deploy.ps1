#!/usr/bin/env pwsh

Write-Host "🚀 Deploying Jenkins on Kubernetes..." -ForegroundColor Cyan

# Create data directory
Write-Host "📁 Creating Jenkins data directory..." -ForegroundColor Yellow
$dataDir = "C:\jenkins-data"
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    Write-Host "✓ Created $dataDir" -ForegroundColor Green
} else {
    Write-Host "✓ Directory $dataDir already exists" -ForegroundColor Green
}

# Apply manifests in order
Write-Host "`n📦 Applying Kubernetes manifests..." -ForegroundColor Yellow

$manifests = @(
    "01-namespace.yaml",
    "02-serviceaccount.yaml",
    "03-volume.yaml",
    "04-configmaps.yaml",
    "05-jenkins.yaml"
)

foreach ($manifest in $manifests) {
    $file = "manifests/$manifest"
    Write-Host "Applying $file..." -ForegroundColor Gray
    kubectl apply -f $file
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Failed to apply $file" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n✓ All manifests applied successfully!" -ForegroundColor Green

# Wait for Jenkins to be ready
Write-Host "`n⏳ Waiting for Jenkins to be ready..." -ForegroundColor Yellow
Write-Host "This may take 2-3 minutes..." -ForegroundColor Gray

$timeout = 300
$elapsed = 0
$ready = $false

while ($elapsed -lt $timeout) {
    $status = kubectl get pods -n devops-tools -l app=jenkins-server -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>$null
    if ($status -eq "True") {
        $ready = $true
        break
    }
    Start-Sleep -Seconds 5
    $elapsed += 5
    Write-Host "." -NoNewline -ForegroundColor Gray
}

Write-Host ""

if ($ready) {
    Write-Host "`n✓ Jenkins is ready!" -ForegroundColor Green
    Write-Host "`n🎉 Deployment complete!" -ForegroundColor Cyan
    Write-Host "`n📋 Access Information:" -ForegroundColor Yellow
    Write-Host "   URL:      http://localhost:32000" -ForegroundColor White
    Write-Host "   Username: admin" -ForegroundColor White
    Write-Host "   Password: admin123" -ForegroundColor White
    Write-Host "`n💡 To watch pods: kubectl get pods -n devops-tools -w" -ForegroundColor Cyan
    Write-Host "💡 To view logs:  kubectl logs -n devops-tools -l app=jenkins-server -f" -ForegroundColor Cyan
} else {
    Write-Host "`n⚠️  Jenkins is taking longer than expected to start" -ForegroundColor Yellow
    Write-Host "Check status with: kubectl get pods -n devops-tools" -ForegroundColor Gray
    Write-Host "Check logs with: kubectl logs -n devops-tools -l app=jenkins-server" -ForegroundColor Gray
}