# =========================
# CONFIG
# =========================
$appKeyword = "Wuthering Waves"

$rootFiles = @(
    "winhttp.dll"
)

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

if (-not (Test-Path $targetPath)) {
    Write-Host "Target path does not exist"
    Read-Host "Press Enter to exit..."
    exit
}

$vietHoaFolder = Join-Path $targetPath "wuwaVietHoa"
$versionFile = Join-Path $targetPath ".latest_version"

# =========================
# CLEAN FILES
# =========================
Write-Host "Cleaning mod files..."

foreach ($file in $rootFiles) {
    $fullPath = Join-Path $targetPath $file
    if (Test-Path $fullPath) {
        Remove-Item $fullPath -Force
        Write-Host "Deleted: $fullPath"
    }
}

foreach ($file in $pakFiles) {
    $fullPath = Join-Path $vietHoaFolder $file
    if (Test-Path $fullPath) {
        Remove-Item $fullPath -Force
        Write-Host "Deleted: $fullPath"
    }
}

if (Test-Path $versionFile) {
    Remove-Item $versionFile -Force
    Write-Host "Deleted: $versionFile"
}

if (Test-Path $vietHoaFolder) {
    $remaining = Get-ChildItem $vietHoaFolder -Force -ErrorAction SilentlyContinue
    if (-not $remaining) {
        Remove-Item $vietHoaFolder -Force
        Write-Host "Removed empty folder: $vietHoaFolder"
    }
}

Write-Host "Mod cleaned successfully!"
Read-Host "Press Enter to exit..."