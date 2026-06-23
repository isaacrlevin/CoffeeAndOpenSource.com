# Publish an Episode

Use this prompt when an episode already exists in `data/guests.json` and is ready to go live.

## Inputs

- Guest slug
- YouTube video ID
- Optional additional links or bio updates

## Goal

Mark the episode as published, fill in the platform links, and commit using the repository's publish trigger format.

## Instructions

1. Find the guest entry in `data/guests.json` by slug.
2. Update the entry in place. Do not reorder unrelated entries.
3. Resolve podcast links before writing platform fields:
   - Check these sources:
     - Amazon: https://isaacl.dev/podcast-amazon
     - Apple: https://isaacl.dev/podcast-apple
     - Spotify: https://isaacl.dev/podcast-spotify
   - Infer the guest identity from the slug and the guest record in `data/guests.json`.
   - For each platform, find whether there is a published episode from the last 7 days whose slug matches the guest slug exactly.
   - If no exact slug match is found, check for an exact guest name match (for example, episode title or listing label equals `GuestName`).
   - If there is an exact slug match or exact guest name match, copy that episode URL for that platform.
   - Do not use partial or fuzzy matches.
   - If no match is found for a platform, leave that platform link unchanged unless the user explicitly provided a verified replacement.
4. Set:
   - `IsPublished` to `true`
   - `HaveAudio` to `true`
   - `YouTubeVideoId` to the supplied value
   - `SpotifyLink`, `AmazonLink`, and `APLink` using the matched URLs discovered in step 3 (or user-supplied verified links when explicitly provided)
5. If the user provides other verified data such as a refined bio or additional links, update those fields too.
6. Do not add `GPLink` unless the user explicitly provides it.
7. If the user does not provide a YouTube video ID and wants help finding it, run `scripts/get-youtube-id.ps1` with the recording date and channel details from environment variables or explicit input.
8. Stage only the files changed for this publish operation.
9. If the user asked to publish, commit with the exact message `PUBLISH|guest-slug`.
10. Push only when the user explicitly wants the workflow triggered immediately or the current branch is already `main`.
11. If the worktree contains unrelated changes, avoid including them in the commit.

## Output expectations

- Summarize the fields updated.
- State which platform URLs were discovered from source pages and which were not found.
- If anything required for publication is still missing, say exactly what is missing.
