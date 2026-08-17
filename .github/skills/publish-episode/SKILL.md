---
name: publish-episode
description: Publish an existing Coffee and Open Source episode. Use when asked to publish, release, or make an existing staged guest episode live.
---

# Publish an Episode

Use this skill when an episode already exists in `data/guests.json` and is ready to go live.

## Inputs

- Guest slug
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
4. Resolve the YouTube video ID:
   - If the user provides a YouTube video ID, use that.
   - If the user does not provide a YouTube video ID, attempt to find it by searching for the guest name and episode title on YouTube. The episode is published in this playlist: https://www.youtube.com/playlist?list=PL_IEvQa-oTVuHpV04ox9jVQbUUQT5V3zm
   - If found, use that video ID. If not found, leave the `YouTubeVideoId` field unchanged unless the user explicitly provides a verified replacement.
5. Set:
   - `IsPublished` to `true`
   - `HaveAudio` to `true`
   - `YouTubeVideoId` to the correct value (either user-supplied or discovered)
   - `SpotifyLink`, `AmazonLink`, and `APLink` using the matched URLs discovered in step 3 (or user-supplied verified links when explicitly provided)
6. If the user provides other verified data such as a refined bio or additional links, update those fields too.
7. Do not add `GPLink` unless the user explicitly provides it.
8. If the user does not provide a YouTube video ID and wants help finding it, run `scripts/get-youtube-id.ps1` with the recording date and channel details from environment variables or explicit input.

## Output expectations

- Summarize the fields updated.
- State which platform URLs were discovered from source pages and which were not found.
- If anything required for publication is still missing, say exactly what is missing.
