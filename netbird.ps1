# ==========================
# 安装 Chocolatey + NetBird
# 适用环境：Windows 10/11
# ==========================

Write-Host "=== 检查是否以管理员运行 ==="
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "请以管理员身份运行此脚本。" -ForegroundColor Red
    exit
}

Write-Host "=== 检查 Chocolatey 是否已安装 ==="
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "未检测到 Chocolatey，正在安装..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey 已存在，跳过安装。" -ForegroundColor Green
}

Write-Host "=== 刷新环境变量 ==="
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine')

Write-Host "=== 安装 NetBird ==="
choco install netbird -y

Write-Host "=== 检查 NetBird 版本 ==="
try {
    netbird version
    Write-Host "NetBird 安装完成！" -ForegroundColor Green
} catch {
    Write-Host "NetBird 安装似乎失败，请检查错误信息。" -ForegroundColor Red
}
