#!/usr/bin/env pwsh

Write-Host "🧹 Cleaning up Jenkins deployment..." -ForegroundColor Cyan

# Delete Kubernetes resources
Write-Host "`n📦 Deleting Kubernetes resources..." -ForegroundColor Yellow
kubectl delete namespace devops-tools --ignore-not-found=true
kubectl delete storageclass local-storage --ignore-not-found=true
kubectl delete pv jenkins-pv-volume --ignore-not-found=true

Write-Host "✓ Kubernetes resources deleted" -ForegroundColor Green

# Ask before deleting data
Write-Host "`n⚠️  Do you want to delete Jenkins data (C:\jenkins-data)? [y/N]" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq 'y' -or $response -eq 'Y') {
    $dataDir = "C:\jenkins-data"
    if (Test-Path $dataDir) {
        Remove-Item -Path $dataDir -Recurse -Force
        Write-Host "✓ Deleted $dataDir" -ForegroundColor Green
    }
} else {
    Write-Host "ℹ️  Jenkins data preserved at C:\jenkins-data" -ForegroundColor Cyan
}

Write-Host "`n✓ Cleanup complete!" -ForegroundColor Green