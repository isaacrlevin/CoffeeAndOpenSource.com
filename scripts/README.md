# Podcast Workflow Helper Scripts

Two PowerShell scripts to automate parts of the Coffee & Open Source episode publishing pipeline.

## Security: Environment Variables

All scripts use environment variables for credentials. **Never commit secrets to version control.**

### Local Development Setup

1. Copy `.env.local.example` to `.env.local` (already in `.gitignore`):
   ```bash
   cp .env.local.example .env.local
   ```

2. Fill in your values in `.env.local`:
   ```
   AZURE_STORAGE_CONNECTION_STRING=your-connection-string-here
   YOUTUBE_API_KEY=your-api-key-here
   YOUTUBE_CHANNEL_ID=your-channel-id-here
   ```

3. Load before running scripts:
   ```powershell
   # Windows PowerShell: Add to your $PROFILE or run manually
   if (Test-Path ".env.local") {
       Get-Content ".env.local" | ForEach-Object {
           if ($_ -and -not $_.StartsWith("#")) {
               $key, $value = $_ -split "=", 2
               [Environment]::SetEnvironmentVariable($key, $value, "Process")
           }
       }
   }
   ```

### GitHub Actions Setup

Store secrets in **Settings → Secrets and variables → Actions**:
- `AZURE_STORAGE_CONNECTION_STRING`
- `YOUTUBE_API_KEY`
- `YOUTUBE_CHANNEL_ID`

Then in workflow YAML, expose them:
```yaml
env:
  AZURE_STORAGE_CONNECTION_STRING: ${{ secrets.AZURE_STORAGE_CONNECTION_STRING }}
  YOUTUBE_API_KEY: ${{ secrets.YOUTUBE_API_KEY }}
  YOUTUBE_CHANNEL_ID: ${{ secrets.YOUTUBE_CHANNEL_ID }}
```

---

## `upload-mp3.ps1`

Upload an MP3 file to Azure Blob Storage in the `interviews` container.

### Prerequisites

- Azure CLI (`az` command)
- `AZURE_STORAGE_CONNECTION_STRING` environment variable set

### Usage

```powershell
# Searches Desktop for files matching the guest slug pattern
.\upload-mp3.ps1 -GuestSlug "guest-name"
```

The script automatically:
1. Searches your Desktop for files matching `guest-name*`
2. Uses the first match found
3. Uploads to Azure Blob Storage in the `interviews` container

---

## `get-youtube-id.ps1`

Search your YouTube channel for recent livestreams/videos and return video IDs.

### Prerequisites

- A YouTube Data API key (from Google Cloud Console)
- Your YouTube channel ID
- Stored in env vars: `YOUTUBE_API_KEY` and `YOUTUBE_CHANNEL_ID`

### Usage

```powershell
# Get the 10 most recent videos
.\get-youtube-id.ps1

# Get first video published after a specific date
.\get-youtube-id.ps1 -PublishedAfter (Get-Date "2026-04-25") -FirstOnly

# Filter by title
.\get-youtube-id.ps1 -TitleContains "Coffee" -FirstOnly
```

### Output

Returns a JSON array of video objects:
```json
[
  {
    "VideoId": "eU0eBzVAlQo",
    "Title": "Coffee and Open Source - Episode Title",
    "PublishedAt": "2026-04-28T15:30:00Z",
    "Url": "https://www.youtube.com/watch?v=eU0eBzVAlQo"
  }
]
```

---

## Copilot Prompts

Two reusable Copilot prompts are in `.github/prompts/`:

- **stage-guest.prompt.md** — Use when you have a new episode scheduled and need to stage it in `data/guests.json`.
- **publish-episode.prompt.md** — Use when an episode is ready to go live and you need to update the links and commit.

In VS Code with Copilot, you can invoke these via `#stage-guest` or `#publish-episode` chat shortcuts (if VS Code has the prompts folder indexed).

---

## Full Workflow Example

### 1. After Recording

Export the MP3 from Adobe Premiere and run:

```powershell
.\scripts\upload-mp3.ps1 -FilePath "C:\exports\episode.mp3" -GuestSlug "guest-name"
```

### 2. Get YouTube Video ID

Once the livestream publishes to YouTube, grab the video ID:

```powershell
$env:YOUTUBE_API_KEY = "your-api-key"
$env:YOUTUBE_CHANNEL_ID = "your-channel-id"
.\scripts\get-youtube-id.ps1 -FirstOnly | jq -r '.VideoId'
```

### 3. Publish to Spotify for Creators

Manually upload to `creators.spotify.com` and collect the platform links.

### 4. Update Data & Commit

Use the `#publish-episode` Copilot prompt with:
- Guest slug
- YouTube video ID
- Spotify, Apple, Amazon links

Copilot will update `data/guests.json` and commit with `PUBLISH|guest-slug`, triggering the GitHub Action to deploy.

---

## Environment Setup

Create a `.env` file (don't commit it) or add to your shell profile:

```bash
export AZURE_STORAGE_ACCOUNT_NAME="your-storage-account"
export YOUTUBE_API_KEY="your-youtube-api-key"
export YOUTUBE_CHANNEL_ID="your-channel-id"
```

Then run the scripts without repeating the flags each time.
