# Publish an Episode

Use this prompt when an episode already exists in `data/guests.json` and is ready to go live.

## Inputs

- Guest slug
- YouTube video ID
- Spotify episode link
- Apple Podcasts link
- Amazon Music link
- Optional additional links or bio updates

## Goal

Mark the episode as published, fill in the platform links, and commit using the repository's publish trigger format.

## Instructions

1. Find the guest entry in `data/guests.json` by slug.
2. Update the entry in place. Do not reorder unrelated entries.
3. Set:
   - `IsPublished` to `true`
   - `HaveAudio` to `true`
   - `YouTubeVideoId` to the supplied value
   - `SpotifyLink`, `AmazonLink`, and `APLink` to the supplied values
4. If the user provides other verified data such as a refined bio or additional links, update those fields too.
5. Do not add `GPLink` unless the user explicitly provides it.
6. If the user does not provide a YouTube video ID and wants help finding it, run `scripts/get-youtube-id.ps1` with the recording date and channel details from environment variables or explicit input.
7. Stage only the files changed for this publish operation.
8. If the user asked to publish, commit with the exact message `PUBLISH|guest-slug`.
9. Push only when the user explicitly wants the workflow triggered immediately or the current branch is already `main`.
10. If the worktree contains unrelated changes, avoid including them in the commit.

## Output expectations

- Summarize the fields updated.
- If anything required for publication is still missing, say exactly what is missing.
