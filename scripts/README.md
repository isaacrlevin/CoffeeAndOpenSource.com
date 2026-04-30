# Podcast Workflow Helper Scripts

Two PowerShell scripts to automate parts of the Coffee & Open Source episode publishing pipeline.

## `upload-mp3.ps1`

Upload an MP3 file to Azure Blob Storage in the `interviews` container.

### Prerequisites

- Azure CLI (`az` command)
- Either:
  - An Azure Storage connection string in `AZURE_STORAGE_CONNECTION_STRING` env var, OR
  - Azure CLI signed in with `az login` and an account name in `AZURE_STORAGE_ACCOUNT_NAME` env var

### Usage

```powershell
# Using connection string
.\upload-mp3.ps1 -FilePath "C:\path\to\episode.mp3" -GuestSlug "guest-name"

# Using az login (default behavior)
$env:AZURE_STORAGE_ACCOUNT_NAME = "your-storage-account"
.\upload-mp3.ps1 -FilePath "C:\path\to\episode.mp3" -GuestSlug "guest-name"
```

### Output

Returns a JSON object with:
- `PublicUrl`: The full CDN URL where the MP3 is now accessible

Example:
```json
{
  "GuestSlug": "guest-name",
  "FilePath": "C:\\path\\to\\episode.mp3",
  "ContainerName": "interviews",
  "BlobName": "guest-name.mp3",
  "PublicUrl": "https://podcasts.coffeeandopensource.com/interviews/guest-name.mp3"
}
```

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
