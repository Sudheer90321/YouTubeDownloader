# YouTubeDownloader

Download YouTube videos and audio using a command line or an AI agent. This is
a portable Windows downloader: it bundles **yt-dlp**, **ffmpeg**, and a helper
script so no installation or other runtimes are needed.

## Folder layout

```
YourFolder\
├── YouTubeDownloader\        <- this repo (the tool)
│   ├── README.md
│   ├── AGENTS.md             <- instructions read by AI assistants
│   ├── download.ps1          <- helper script for VIDEOS
│   ├── yt-dlp.exe            <- the downloader (Git LFS)
│   └── ffmpeg.exe            <- merging / audio conversion (Git LFS)
└── YouTubeDownloads\         <- ALL downloads land here automatically
```

Video, audio, and playlist files are saved to the sibling folder
**`YouTubeDownloads`** (created automatically) so the repo itself never fills
up with media.

| File | Purpose |
|------|---------|
| `yt-dlp.exe` | The downloader program |
| `ffmpeg.exe` | Merges video + audio streams, converts audio (e.g. to MP3) |
| `download.ps1` | Helper script for **video** downloads (quality, playlists, speed limits) |

---

## Using this repo in an AI-based IDE

You can drive the downloader by chatting with the AI assistant in any AI IDE
(Cursor, VS Code, Windsurf, Zed, opencode, Claude Code, ...) instead of typing
commands yourself.

1. Clone this repo (see below) and open the repo folder as the project/workspace
   in your AI IDE.
2. Make sure the IDE terminal opens in the repo **root** (the folder that
   contains `download.ps1` and `yt-dlp.exe`). If not, `cd` there first.
3. Just ask, for example:
   - "download this video: <URL>"
   - "download audio only from this video: <URL>"
   - "download this playlist: <URL>"
4. The `AGENTS.md` file in the repo tells the assistant exactly how: which
   commands to run, where files are saved, and how to verify each download.
   Downloaded files land in `YouTubeDownloads` next to this folder.

Requirements: Windows with PowerShell (built-in). No Node, Python, or other
runtimes needed.

---

## Cloning (for a new user)

The two `.exe` files are stored with Git LFS, so install Git LFS first, or the
clone will contain invalid pointer files.

```bash
git lfs install
git clone https://github.com/Sudheer90321/YouTubeDownloader.git
cd YouTubeDownloader
```

If you cloned before installing Git LFS, fetch the real binaries after:

```bash
git lfs pull
```

Then open the folder in your AI IDE (terminal in the repo root) and ask the
assistant for a video / audio / playlist download.

---

## Step 1 - Open PowerShell in the tool folder

1. Open the `YouTubeDownloader` folder (File Explorer).
2. Click the **address bar** at the top.
3. Type `powershell` and press **Enter**.

A PowerShell window opens inside the folder with `yt-dlp.exe`.

---

## Step 2 - Download a VIDEO (default 1080p)

Use the helper script. It picks a 1080p H.264 video and merges it with the best
audio via the bundled ffmpeg, saving it to `..\YouTubeDownloads`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "VIDEO_URL"
```

Example:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

- `-ExecutionPolicy Bypass` is required because this machine blocks `.ps1` scripts.
- Saved as `..\YouTubeDownloads\TITLE [VIDEO_ID].mp4`.

### Choose a different quality

Add `-Quality` with a number (`720`, `1080`, `2160`), `4k`/`2k`/`8k`, or `best`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "URL" -Quality 720
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "URL" -Quality 4k
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "URL" -Quality best
```

### Save to a custom folder

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "URL" -Path "D:\Videos"
```

### Cap the download speed (leave bandwidth free)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "URL" -RateLimit 1
```

### Preview without downloading

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "URL" -Simulate
```

---

## Step 3 - Download a PLAYLIST

The helper script detects playlists automatically and saves each video as
`NNN - TITLE [ID].mp4` inside `..\YouTubeDownloads\<Playlist Title>\`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "PLAYLIST_URL"
```

Only download videos 1-5 of the playlist:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\download.ps1" -Url "PLAYLIST_URL" -PlaylistItems "1-5"
```

---

## Step 4 - Download AUDIO only (MP3)

The helper script is video-only, so use `yt-dlp.exe` directly. This extracts the
best audio and converts it to MP3 with ffmpeg, saving it to `..\YouTubeDownloads`.

```powershell
.\yt-dlp.exe --ffmpeg-location ".\ffmpeg.exe" --paths "..\YouTubeDownloads" -x --audio-format mp3 --audio-quality 0 -o "%(title)s [%(id)s].%(ext)s" "VIDEO_URL"
```

Example:

```powershell
.\yt-dlp.exe --ffmpeg-location ".\ffmpeg.exe" --paths "..\YouTubeDownloads" -x --audio-format mp3 --audio-quality 0 -o "%(title)s [%(id)s].%(ext)s" "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

- `--paths "..\YouTubeDownloads"` saves the MP3 in the downloads folder (add it
  when you run from this tool folder).
- `-x` extracts audio only
- `--audio-format mp3` converts to MP3
- `--audio-quality 0` = best MP3 quality (0-9, 0 is best)

### Audio only, other formats

Replace `mp3` with `m4a`, `opus`, `wav`, or `flac` as desired:

```powershell
.\yt-dlp.exe --ffmpeg-location ".\ffmpeg.exe" --paths "..\YouTubeDownloads" -x --audio-format m4a -o "%(title)s [%(id)s].%(ext)s" "VIDEO_URL"
```

---

## Step 5 - Update yt-dlp

If downloads start failing (YouTube changes frequently), update yt-dlp:

```powershell
.\yt-dlp.exe -U
```

Run this periodically - it fixes the most common download errors.

---

## Step 6 - Troubleshooting

- **"No supported JavaScript runtime could be found"** - this warning is
  expected on this machine; downloads still work.
- **HTTP 403 / format errors** - update yt-dlp first (`.\yt-dlp.exe -U`), then
  retry. If it still fails, report the last error lines.
- **Video has no sound** - never use `bestvideo` without `+bestaudio`; the
  helper script always merges both.
- **Exe files are tiny / LFS pointers** - run `git lfs pull`.
- If a download fails, yt-dlp prints the reason - share those lines for help.

---

## Notes

- Replace `VIDEO_URL` / `PLAYLIST_URL` with the actual link.
- The large `ffmpeg.exe` (and `yt-dlp.exe`) are tracked with Git LFS in this repo.
- This is a Windows tool. On macOS/Linux, install yt-dlp + ffmpeg and use equivalent commands.
- Some sites may block downloads or require login (also see `--cookies-from-browser` in yt-dlp docs).
- Respect copyright and the website's terms of service.