# download.ps1 - YouTube video/playlist downloader wrapper (portable)
# Usage:
#   & ".\download.ps1" -Url "https://..." [-Quality 1080] [-Path "C:\..."] [-PlaylistItems "1-5"] [-RateLimit 5]
# Portable: finds yt-dlp.exe and ffmpeg.exe in the same folder as this script.
# Downloads are saved to the sibling folder "YouTubeDownloads" (next to this
# script's parent) by default; override with -Path.
# Quality: number (e.g. 720, 1080, 2160), "4k"/"2k"/"8k", or "best". Default: 1080.
# RateLimit: optional download speed cap to reserve network bandwidth.
#   Plain number = megabits per second (e.g. 1, 5, 10 -> converted to bytes).
#   K/M/G suffix  = yt-dlp byte notation, passed through (e.g. 500K, 1M).

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Url,
    [string]$Quality = "1080",
    [string]$Path = "",
    [string]$PlaylistItems = "",
    [switch]$Simulate,
    [string]$RateLimit = ""
)

$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
# Default save folder: the sibling "YouTubeDownloads" folder next to the parent of this script.
if (-not $Path) {
    $Path = Join-Path (Split-Path $ScriptDir -Parent) "YouTubeDownloads"
}
$YtDlp = Join-Path $ScriptDir "yt-dlp.exe"
$Ffmpeg = Join-Path $ScriptDir "ffmpeg.exe"

if (-not (Test-Path -LiteralPath $YtDlp)) {
    Write-Host "ERROR: yt-dlp not found at $YtDlp" -ForegroundColor Red
    exit 1
}

$q = $Quality.Trim().ToLower().TrimEnd("p")
switch ($q) {
    "best" { $height = 0 }
    "auto" { $height = 0 }
    "all"  { $height = 0 }
    "8k"   { $height = 4320 }
    "4k"   { $height = 2160 }
    "2k"   { $height = 1440 }
    default {
        if ($q -match "^[0-9]+$") { $height = [int]$q }
        else {
            Write-Host "ERROR: Quality must be a number (720, 1080, 2160...), '4k'/'2k'/'8k', or 'best'. Got: '$Quality'" -ForegroundColor Red
            exit 1
        }
    }
}

if ($height -eq 0) {
    $Format = "bestvideo+bestaudio/best"
} else {
    $Format = "bestvideo[height<=$height][vcodec^=avc1]+bestaudio[ext=m4a]/bestvideo[height<=$height]+bestaudio/best[height<=$height]/best"
}

$rateArg = ""
$rateLabel = "no limit"
if ($RateLimit) {
    if ($RateLimit -match "^[0-9]+(\.[0-9]+)?$") {
        # Plain number -> megabits per second. 1 Mbps = 1,000,000 bits/s / 8 = 125,000 bytes/s.
        $mbps = [double]$RateLimit
        if ($mbps -le 0) {
            Write-Host "ERROR: RateLimit must be greater than 0. Got: '$RateLimit'" -ForegroundColor Red
            exit 1
        }
        $rateBytes = [math]::Round($mbps * 125000)
        $rateArg = "$rateBytes"
        $rateLabel = "${mbps} Mbps"
    } elseif ($RateLimit -match "^[0-9]+(\.[0-9]+)?[KMG](i?B)?$") {
        # yt-dlp byte notation (e.g. 500K, 1M, 2.5M) -> pass through verbatim.
        $rateArg = $RateLimit.Trim()
        $rateLabel = "$RateLimit (yt-dlp byte notation)"
    } else {
        Write-Host "ERROR: RateLimit must be a number in Mbps (e.g. 1, 5, 10) or yt-dlp byte notation (e.g. 500K, 1M). Got: '$RateLimit'" -ForegroundColor Red
        exit 1
    }
}

$isPlaylist = $Url -match "[?&]list="
if ($isPlaylist) {
    $outTemplate = "%(playlist_title)s\%(playlist_index)03d - %(title)s [%(id)s].%(ext)s"
} else {
    $outTemplate = "%(title)s [%(id)s].%(ext)s"
}

if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

$dlArgs = @(
    "--ffmpeg-location", $Ffmpeg,
    "--paths", $Path,
    "-f", $Format,
    "--merge-output-format", "mp4/mkv",
    "-o", $outTemplate
)
if ($PlaylistItems) { $dlArgs += @("--playlist-items", $PlaylistItems) }
if ($Simulate) { $dlArgs += @("--simulate", "--no-warnings") }
if ($rateArg) { $dlArgs += @("--limit-rate", $rateArg) }
$dlArgs += $Url

$qualityLabel = if ($height -eq 0) { "best (unlimited)" } else { "${height}p" }
Write-Host "Downloading: $Url" -ForegroundColor Cyan
Write-Host "Quality: $qualityLabel | Mode: $(if ($isPlaylist) { 'PLAYLIST (serial-numbered subfolder)' } else { 'single video' }) | Save: $Path | Rate limit: $rateLabel" -ForegroundColor Cyan
Write-Host "yt-dlp: $YtDlp $($dlArgs -join ' ')" -ForegroundColor DarkGray

& $YtDlp @dlArgs
exit $LASTEXITCODE
