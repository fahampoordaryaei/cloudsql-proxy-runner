@echo off
setlocal

where gcloud >nul 2>&1
if errorlevel 1 (
  echo gcloud not found. Installing Google Cloud SDK...
  where winget >nul 2>&1
  if errorlevel 1 (
    echo winget is not available. Install Google Cloud SDK manually:
    echo https://cloud.google.com/sdk/docs/install
    exit /b 1
  )
  winget install --id Google.CloudSDK --exact --source winget --accept-source-agreements --accept-package-agreements
  if errorlevel 1 (
    echo Failed to install Google Cloud SDK.
    exit /b 1
  )
)

echo Refreshing environment variables...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1; refreshenv"

echo Running ADC login...
call gcloud auth application-default login
if errorlevel 1 (
  echo gcloud auth application-default login failed.
  exit /b 1
)

set "PROXY_EXE=%~dp0cloud-sql-proxy.x64.exe"
set "PROXY_URL=https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.21.1/cloud-sql-proxy.x64.exe"

echo Downloading Cloud SQL Proxy...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%PROXY_URL%' -OutFile '%PROXY_EXE%'"
if errorlevel 1 (
  echo Failed to download cloud-sql-proxy.x64.exe
  exit /b 1
)

echo Starting Cloud SQL Proxy on port 5433...
"%PROXY_EXE%" --auto-iam-authn --port 5433 makecents-b0fb9:europe-west1:makecents-b0fb9-database

endlocal
