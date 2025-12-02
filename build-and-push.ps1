# Configuration
$DOCKER_HUB_USER = "chienvm"
$VERSION_TAG = "v1.0.0"  # Thay đổi tag version nếu cần
$PLATFORM = "linux/amd64"

# Đọc version từ .env file (nếu có)
$envFile = "docker\.env"
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile
    $WREN_ENGINE_VERSION = ($envContent | Select-String "WREN_ENGINE_VERSION=(.+)").Matches.Groups[1].Value
    $IBIS_SERVER_VERSION = ($envContent | Select-String "IBIS_SERVER_VERSION=(.+)").Matches.Groups[1].Value
    $WREN_UI_VERSION = ($envContent | Select-String "WREN_UI_VERSION=(.+)").Matches.Groups[1].Value
    $WREN_AI_SERVICE_VERSION = ($envContent | Select-String "WREN_AI_SERVICE_VERSION=(.+)").Matches.Groups[1].Value
    $WREN_BOOTSTRAP_VERSION = ($envContent | Select-String "WREN_BOOTSTRAP_VERSION=(.+)").Matches.Groups[1].Value
} else {
    Write-Host "Warning: .env file not found, using default versions" -ForegroundColor Yellow
    $WREN_ENGINE_VERSION = "latest"
    $IBIS_SERVER_VERSION = "latest"
    $WREN_UI_VERSION = "latest"
    $WREN_AI_SERVICE_VERSION = "latest"
    $WREN_BOOTSTRAP_VERSION = "latest"
}

Write-Host "=== Building and Pushing All Images to Docker Hub ===" -ForegroundColor Blue
Write-Host "Docker Hub User: $DOCKER_HUB_USER" -ForegroundColor Cyan
Write-Host "Version Tag: $VERSION_TAG" -ForegroundColor Cyan
Write-Host ""

# Login to Docker Hub
Write-Host "[LOGIN] Logging in to Docker Hub..." -ForegroundColor Green
docker login
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker login failed!" -ForegroundColor Red
    exit 1
}

# 1. Build wren-ui
Write-Host "`n[1/5] Building wren-ui..." -ForegroundColor Green
Set-Location wren-ui
docker build --platform $PLATFORM -t "${DOCKER_HUB_USER}/wren-ui:${VERSION_TAG}" -t "${DOCKER_HUB_USER}/wren-ui:latest" -t "${DOCKER_HUB_USER}/wren-ui:${WREN_UI_VERSION}" -f Dockerfile .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build wren-ui!" -ForegroundColor Red
    Set-Location ..
    exit 1
}
docker push "${DOCKER_HUB_USER}/wren-ui:${VERSION_TAG}"
docker push "${DOCKER_HUB_USER}/wren-ui:latest"
docker push "${DOCKER_HUB_USER}/wren-ui:${WREN_UI_VERSION}"
Set-Location ..
Write-Host "✓ wren-ui built and pushed successfully" -ForegroundColor Green

# 2. Build wren-ai-service
Write-Host "`n[2/5] Building wren-ai-service..." -ForegroundColor Green
Set-Location wren-ai-service
docker build --platform $PLATFORM -t "${DOCKER_HUB_USER}/wren-ai-service:${VERSION_TAG}" -t "${DOCKER_HUB_USER}/wren-ai-service:latest" -t "${DOCKER_HUB_USER}/wren-ai-service:${WREN_AI_SERVICE_VERSION}" -f docker/Dockerfile .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build wren-ai-service!" -ForegroundColor Red
    Set-Location ..
    exit 1
}
docker push "${DOCKER_HUB_USER}/wren-ai-service:${VERSION_TAG}"
docker push "${DOCKER_HUB_USER}/wren-ai-service:latest"
docker push "${DOCKER_HUB_USER}/wren-ai-service:${WREN_AI_SERVICE_VERSION}"
Set-Location ..
Write-Host "✓ wren-ai-service built and pushed successfully" -ForegroundColor Green

# 3. Build bootstrap
Write-Host "`n[3/5] Building bootstrap..." -ForegroundColor Green
Set-Location docker/bootstrap
docker build --platform $PLATFORM -t "${DOCKER_HUB_USER}/wren-bootstrap:${VERSION_TAG}" -t "${DOCKER_HUB_USER}/wren-bootstrap:latest" -t "${DOCKER_HUB_USER}/wren-bootstrap:${WREN_BOOTSTRAP_VERSION}" -f Dockerfile .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build bootstrap!" -ForegroundColor Red
    Set-Location ../..
    exit 1
}
docker push "${DOCKER_HUB_USER}/wren-bootstrap:${VERSION_TAG}"
docker push "${DOCKER_HUB_USER}/wren-bootstrap:latest"
docker push "${DOCKER_HUB_USER}/wren-bootstrap:${WREN_BOOTSTRAP_VERSION}"
Set-Location ../..
Write-Host "✓ bootstrap built and pushed successfully" -ForegroundColor Green

# 4. Pull and re-tag wren-engine
Write-Host "`n[4/5] Pulling and re-tagging wren-engine (version: $WREN_ENGINE_VERSION)..." -ForegroundColor Green
docker pull "ghcr.io/canner/wren-engine:${WREN_ENGINE_VERSION}"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to pull wren-engine!" -ForegroundColor Red
    exit 1
}
docker tag "ghcr.io/canner/wren-engine:${WREN_ENGINE_VERSION}" "${DOCKER_HUB_USER}/wren-engine:${VERSION_TAG}"
docker tag "ghcr.io/canner/wren-engine:${WREN_ENGINE_VERSION}" "${DOCKER_HUB_USER}/wren-engine:latest"
docker tag "ghcr.io/canner/wren-engine:${WREN_ENGINE_VERSION}" "${DOCKER_HUB_USER}/wren-engine:${WREN_ENGINE_VERSION}"
docker push "${DOCKER_HUB_USER}/wren-engine:${VERSION_TAG}"
docker push "${DOCKER_HUB_USER}/wren-engine:latest"
docker push "${DOCKER_HUB_USER}/wren-engine:${WREN_ENGINE_VERSION}"
Write-Host "✓ wren-engine pulled and pushed successfully" -ForegroundColor Green

# 5. Pull and re-tag ibis-server
Write-Host "`n[5/5] Pulling and re-tagging ibis-server (version: $IBIS_SERVER_VERSION)..." -ForegroundColor Green
docker pull "ghcr.io/canner/wren-engine-ibis:${IBIS_SERVER_VERSION}"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to pull ibis-server!" -ForegroundColor Red
    exit 1
}
docker tag "ghcr.io/canner/wren-engine-ibis:${IBIS_SERVER_VERSION}" "${DOCKER_HUB_USER}/wren-engine-ibis:${VERSION_TAG}"
docker tag "ghcr.io/canner/wren-engine-ibis:${IBIS_SERVER_VERSION}" "${DOCKER_HUB_USER}/wren-engine-ibis:latest"
docker tag "ghcr.io/canner/wren-engine-ibis:${IBIS_SERVER_VERSION}" "${DOCKER_HUB_USER}/wren-engine-ibis:${IBIS_SERVER_VERSION}"
docker push "${DOCKER_HUB_USER}/wren-engine-ibis:${VERSION_TAG}"
docker push "${DOCKER_HUB_USER}/wren-engine-ibis:latest"
docker push "${DOCKER_HUB_USER}/wren-engine-ibis:${IBIS_SERVER_VERSION}"
Write-Host "✓ ibis-server pulled and pushed successfully" -ForegroundColor Green

Write-Host "`n=== All images built and pushed successfully! ===" -ForegroundColor Green
Write-Host "Note: qdrant will use official image qdrant/qdrant:v1.11.0 (no need to push separately)" -ForegroundColor Cyan
Write-Host "`nYour images are available at:" -ForegroundColor Cyan
Write-Host "  - ${DOCKER_HUB_USER}/wren-ui:${VERSION_TAG}" -ForegroundColor White
Write-Host "  - ${DOCKER_HUB_USER}/wren-ai-service:${VERSION_TAG}" -ForegroundColor White
Write-Host "  - ${DOCKER_HUB_USER}/wren-bootstrap:${VERSION_TAG}" -ForegroundColor White
Write-Host "  - ${DOCKER_HUB_USER}/wren-engine:${VERSION_TAG}" -ForegroundColor White
Write-Host "  - ${DOCKER_HUB_USER}/wren-engine-ibis:${VERSION_TAG}" -ForegroundColor White
Write-Host "`nNext step: Update docker-compose-prod.yaml and .env file to use these images" -ForegroundColor Yellow