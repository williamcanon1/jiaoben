# ==========================
# 安装/更新 NetBird 并注册到自建服务器
# 固定 Setup Key，运行时询问 URL
# ==========================

# ====== 固定 Setup Key（请替换为你的 Key） ======
$setupKey  = "6E7D9F90-4F86-485A-9C5B-E39242BC5D85"
# ===============================================

Write-Host "=== 检查是否以管理员运行 ==="
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "请以管理员身份运行此脚本。" -ForegroundColor Red
    exit
}

# 让用户输入服务器 URL
$serverUrl = Read-Host "请输入你的 NetBird 管理服务器 URL (例如 https://netbird.example.com )"

if ([string]::IsNullOrWhiteSpace($serverUrl)) {
    Write-Host "未输入服务器 URL，脚本终止。" -ForegroundColor Red
    exit
}

Write-Host "`n=== 检查 Chocolatey 是否已安装 ==="
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "未检测到 Chocolatey，正在安装..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey 已存在，跳过安装。" -ForegroundColor Green
}

# 刷新环境变量
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine')

Write-Host "`n=== 检查 NetBird 是否已安装 ==="
$netbirdCmd = Get-Command netbird -ErrorAction SilentlyContinue

if ($null -eq $netbirdCmd) {
    Write-Host "未检测到 NetBird，开始安装..." -ForegroundColor Yellow
    choco install netbird -y
} else {
    Write-Host "检测到 NetBird 已安装，检查更新..." -ForegroundColor Green
    choco upgrade netbird -y
}

Write-Host "`n=== 验证 NetBird 是否正常 ==="
try {
    $version = netbird version
    Write-Host "NetBird 已安装并可用，版本: $version" -ForegroundColor Green
} catch {
    Write-Host "NetBird 验证失败，请手动检查安装路径。" -ForegroundColor Red
    exit
}

Write-Host "`n=== 注册到自建 NetBird 服务器 ==="
try {
    netbird up --management-url $serverUrl --setup-key $setupKey
    Write-Host "NetBird 已成功注册并上线到 $serverUrl" -ForegroundColor Green
    netbird status
} catch {
    Write-Host "注册失败，请检查 URL 和 Setup Key 是否正确。" -ForegroundColor Red
}

# 开机自启
Write-Host "`n=== 配置 NetBird 服务开机自启 ==="
try {
    netbird service install
    netbird service start
    Write-Host "NetBird 服务已设置为开机自启并启动。" -ForegroundColor Green
} catch {
    Write-Host "无法配置开机自启，请手动执行 netbird service install/start" -ForegroundColor Yellow
}
