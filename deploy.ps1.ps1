# Hero PID Hub - GitHub Deploy Script
# Run this whenever Claude has an update ready
 
$token = "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"
$owner = "Cameron-fanatics"
$repo = "hero-pid-hub"
$filePath = "index.html"
$localFile = $localFile = "C:\Users\Cameron.Thompson\OneDrive - Fanatics, Inc\Desktop\Hero PID Hub\index.html"
$commitMessage = "Update Hero PID Hub"
 
# Read the local file
if (-not (Test-Path $localFile)) {
    Write-Host "ERROR: index.html not found next to this script." -ForegroundColor Red
    Write-Host "Make sure index.html is in the same folder as this .ps1 file." -ForegroundColor Yellow
    pause
    exit
}
 
$content = [System.IO.File]::ReadAllBytes($localFile)
$base64 = [System.Convert]::ToBase64String($content)
 
# Get current file SHA (needed for updates)
$headers = @{
    Authorization = "token $token"
    Accept = "application/vnd.github.v3+json"
    "User-Agent" = "HeroPIDHub-Deploy"
}
 
$apiUrl = "https://api.github.com/repos/$owner/$repo/contents/$filePath"
 
Write-Host "Fetching current file SHA..." -ForegroundColor Cyan
try {
    $current = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
    $sha = $current.sha
    Write-Host "Current SHA: $sha" -ForegroundColor Green
} catch {
    Write-Host "File not found on GitHub - will create new file." -ForegroundColor Yellow
    $sha = $null
}
 
# Build request body
$body = @{
    message = $commitMessage
    content = $base64
} 
if ($sha) { $body.sha = $sha }
 
$bodyJson = $body | ConvertTo-Json
 
# Push to GitHub
Write-Host "Pushing index.html to GitHub..." -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Put -Body $bodyJson -ContentType "application/json"
    Write-Host "SUCCESS! Deployed to GitHub Pages." -ForegroundColor Green
    Write-Host "URL: https://$owner.github.io/$repo/" -ForegroundColor Cyan
    Write-Host "Note: GitHub Pages may take 30-60 seconds to update." -ForegroundColor Yellow
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Check your token has repo permissions and hasn't expired." -ForegroundColor Yellow
}
 
pause