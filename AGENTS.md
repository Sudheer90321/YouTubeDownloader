# YouTubeDownloader - Instructions for AI assistants

You are working in a portable Windows YouTube downloader that bundles its own
tools. A user in an AI-based IDE (Cursor, VS Code + Copilot, Windsurf, opencode,
Claude Code, ...) will ask you to download a **video**, a **playlist**, or
**audio only** from a YouTube (or other supported site) URL. Help them end to
end: run the right command, then confirm the files and report the paths.

## Tools (already bundled - do NOT install anything)

| File | Purpose |
|------|---------|
| `yt-dlp.exe` | The downloader program |
| `ffmpeg.exe` | Merges video + audio, converts to MP3 |
| `download.ps1` | Wrapper for VIDEO downloads (quality, playlists, rate limits) |

## Run commands from the repo root

Always run commands from THIS folder (the folder containing `yt-dlp.exe`), so
the relative paths below are correct. The IDE terminal usually opens here.

## Where files are saved

- All downloads default to the sibling folder `..\YouTubeDownloads` (one level
  above this repo; auto-created, not inside the repo, not in git).
- Video/playlist via `download.ps1` goes there automatically.
- Audio commands below pass `--paths "..\YouTubeDownloads"` explicitly.

## VIDEO download (default 1080p)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "VIDEO_URL"
```

- `-ExecutionPolicy Bypass` is REQUIRED - this machine blocks `.ps1` scripts.
- Saved as `..\YouTubeDownloads\TITLE [VIDEO_ID].mp4`.

Quality options: `-Quality 720`, `-Quality 2160`, `-Quality 4k`, `-Quality best`, ...

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "URL" -Quality 4k
```

Override the save folder: `-Path "C:\Videos"`.

### Playlist

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "PLAYLIST_URL"
# Only videos 1-5:
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "PLAYLIST_URL" -PlaylistItems "1-5"
```

Playlists save as `..\YouTubeDownloads\PLAYLIST_TITLE\NNN - TITLE [ID].mp4`.

### Rate limit (optional, leaves bandwidth free)

Add `-RateLimit 1` (1 Mbps), `-RateLimit 5`, `-RateLimit 10`, or byte
notation like `1M`.

### Preview without downloading

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "URL" -Simulate
```

## AUDIO only (MP3) - the helper script is video-only

The wrapper is video-only. Use `yt-dlp.exe` directly for audio:

```powershell
.\yt-dlp.exe --ffmpeg-location ".\ffmpeg.exe" --paths "..\YouTubeDownloads" -x --audio-format mp3 --audio-quality 0 -o "%(title)s [%(id)s].%(ext)s" "VIDEO_URL"
```

Other audio formats: replace `mp3` with `m4a`, `opus`, `wav`, or `flac`.

## Always verify after a download

List the newest files and tell the user the exact absolute file path(s):

```powershell
Get-ChildItem "..\YouTubeDownloads" | Sort-Object LastWriteTime -Descending | Select-Object -First 6
```

## Notes for non-Windows users

This repo ships Windows executables and a `.ps1` script. On macOS/Linux,
the bundled exes do not run - tell the user to install `yt-dlp` + `ffmpeg`
themselves and use the equivalent raw commands (e.g. `yt-dlp -x
--audio-format mp3 "URL"`).

## Troubleshooting

- The warning "No supported JavaScript runtime could be found" is EXPECTED on
  this machine; downloads still work.
- HTTP 403 / missing formats: update first: `.\yt-dlp.exe -U`, then retry.
- NEVER use `bestvideo` without `+bestaudio` - the file would have no sound.
- If a download fails, report the last yt-dlp error lines to the user; do not
  hide them.
- Respect copyright and the website's terms of service.