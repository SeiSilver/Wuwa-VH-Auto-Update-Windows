$owner = "CallMeDangDev"
$repo = "WuwaVH"
$api = "https://api.github.com/repos/$owner/$repo/releases/latest"
Write-Host $api

# keyword to search app
$appKeyword = "Wuthering Waves"

# All required files
$targetFiles = @(
    "winhttp.dll",
    "WuWaVH_99_P.pak",
    "Signika-Bold_100_P.pak"
)

# Files in Win64 root
$rootFiles = @(
    "winhttp.dll"
)

# Files in Win64\wuwaVietHoa
$pakFiles = @(
    "WuWaVH_99_P.pak",
    "Signika-Bold_100_P.pak"
)

# =========================
# FIND INSTALL PATH
# =========================
function Find-InstallPath {
    param ([string]$keyword)

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $paths) {
        $result = Get-ItemProperty $path -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*$keyword*" -and $_.InstallLocation } |
            Select-Object -First 1

        if ($result) {
            Write-Host "Matched app:" $result.DisplayName
            return $result.InstallLocation
        }
    }

    return $null
}

# =========================
# GET INSTALL PATH
# =========================
$installPath = Find-InstallPath $appKeyword

if (-not $installPath) {
    Write-Host "App not found"
    $installPath = Read-Host "Enter game root path"
}

if (-not (Test-Path $installPath)) {
    Write-Host "Path does not exist"
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "Root path: $installPath"

# =========================
# AUTO DETECT WIN64
# =========================
Write-Host "Searching Win64 folder..."

$targetPath = Get-ChildItem $installPath -Recurse -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*\Client\Binaries\Win64" } |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $targetPath) {
    Write-Host "Cannot auto detect Win64 folder"
    $targetPath = Read-Host "Enter Win64 path"
}

# =========================
# VALIDATE FOLDER
# =========================
if (-not (Test-Path $targetPath)) {
    Write-Host "Target path does not exist"
    Read-Host "Press Enter to exit..."
    exit
}

$exeFile = Get-ChildItem $targetPath -Filter "Client-Win64-Shipping.exe" -ErrorAction SilentlyContinue |
    Select-Object -First 1

if (-not $exeFile) {
    Write-Host "No .exe found. Wrong folder?"
    Write-Host "Target: $targetPath"
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "Target path: $targetPath"
Write-Host "Detected exe: $($exeFile.Name)"

# =========================
# DEFINE PATHS
# =========================
$vietHoaFolder = Join-Path $targetPath "wuwaVietHoa"
$versionFile = Join-Path $targetPath ".latest_version"

# =========================
# CHECK VERSION
# =========================
Write-Host "Checking latest version..."

try {
    $response = Invoke-RestMethod -Uri $api
}
catch {
    Write-Host "Cannot connect to GitHub API"
    Read-Host "Press Enter to exit..."
    exit
}

$latestVersion = $response.tag_name

# Check mod exists
$modExists = $true

# version.dll in Win64
foreach ($file in $rootFiles) {
    if (-not (Test-Path (Join-Path $targetPath $file))) {
        $modExists = $false
        break
    }
}

# pak files in wuwaVietHoa
if ($modExists) {
    foreach ($file in $pakFiles) {
        if (-not (Test-Path (Join-Path $vietHoaFolder $file))) {
            $modExists = $false
            break
        }
    }
}

# Read current version
if (Test-Path $versionFile) {
    $currentVersion = (Get-Content $versionFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
}
else {
    $currentVersion = ""
}

Write-Host "Latest: $latestVersion"
Write-Host "Current: $currentVersion"
Write-Host "Mod installed: $modExists"

if ($modExists -and $latestVersion -eq $currentVersion) {
    Write-Host "No update needed"
    Read-Host "Press Enter to exit..."
    exit
}

if (-not $modExists) {
    Write-Host "Mod not installed. Will download"
}

# =========================
# STRICT CHECK FILE
# =========================
$foundFiles = @()

foreach ($asset in $response.assets) {
    if ($targetFiles -contains $asset.name) {
        $foundFiles += $asset.name
    }
}

if ($foundFiles.Count -ne $targetFiles.Count) {
    Write-Host "ERROR: Missing required files"
    Write-Host "Expected: $($targetFiles -join ', ')"
    Write-Host "Found: $($foundFiles -join ', ')"
    Read-Host "Press Enter to exit..."
    exit
}

# =========================
# CREATE wuwaVietHoa FOLDER
# =========================
if (-not (Test-Path $vietHoaFolder)) {
    Write-Host "Creating folder: $vietHoaFolder"
    New-Item -ItemType Directory -Path $vietHoaFolder -Force | Out-Null
}

# =========================
# DELETE OLD FILES
# =========================
Write-Host "Cleaning old files..."

# Delete root files
foreach ($file in $rootFiles) {
    $fullPath = Join-Path $targetPath $file
    if (Test-Path $fullPath) {
        Remove-Item $fullPath -Force
        Write-Host "Deleted: $fullPath"
    }
}

# Delete pak files
foreach ($file in $pakFiles) {
    $fullPath = Join-Path $vietHoaFolder $file
    if (Test-Path $fullPath) {
        Remove-Item $fullPath -Force
        Write-Host "Deleted: $fullPath"
    }
}

# =========================
# DOWNLOAD FILES
# =========================
Write-Host "Downloading..."

# Force TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create WebClient once
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "WuwaVH-Updater")

foreach ($asset in $response.assets) {
    $name = $asset.name
    $url = $asset.browser_download_url

    # version.dll -> Win64
    if ($rootFiles -contains $name) {
        $destination = Join-Path $targetPath $name
    }
    # pak files -> Win64\wuwaVietHoa
    elseif ($pakFiles -contains $name) {
        $destination = Join-Path $vietHoaFolder $name
    }
    else {
        continue
    }

    Write-Host "Downloading: $name"
    Write-Host "To: $destination"

    try {
        # Delete partial file if exists
        if (Test-Path $destination) {
            Remove-Item $destination -Force
        }

        # Download file
        $wc.DownloadFile($url, $destination)

        Write-Host "Downloaded: $name"
    }
    catch {
        Write-Host "Failed to download: $name"
        Write-Host $_.Exception.Message

        $wc.Dispose()
        Read-Host "Press Enter to exit..."
        exit
    }
}

# Cleanup WebClient
$wc.Dispose()

# =========================
# SAVE VERSION
# =========================
$latestVersion | Out-File $versionFile -Encoding utf8

Write-Host "Done! Updated to version $latestVersion"

Read-Host "Press Enter to exit..."