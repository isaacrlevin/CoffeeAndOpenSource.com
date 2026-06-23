# Coffee and Open Source repository instructions

This repository is a Hugo site for the Coffee and Open Source podcast.

## Core content model

- The authoritative episode data lives in `data/guests.json`.
- `data/guests.json` is a single JSON object keyed by the guest slug, for example `"joe-finney"`.
- Each guest entry normally contains these fields in this order:
  - `PartitionKey`
  - `RowKey`
  - `DateTimeAsString`
  - `DateTimeUTC`
  - `GuestName`
  - `GuestHandle`
  - `GuestLink`
  - `IsPublished`
  - `Topic`
  - `YouTubeVideoId`
  - `GuestBio`
  - `HaveAudio`
  - `SpotifyLink`
  - `AmazonLink`
  - `APLink`
  - `Socials`
  - optional `Links`
- Older entries may also contain `GPLink`. Do not add `GPLink` to new entries unless the user explicitly provides it.
- `Socials` is an array of single-key objects such as `{ "GitHub": "https://github.com/example" }`.
- `Links` is optional and is also an array of single-key objects.

## Staged vs published entries

- A staged episode uses `IsPublished: false`.
- A staged episode normally uses:
  - empty `YouTubeVideoId`
  - empty platform links
  - `HaveAudio: false`
- A published episode uses `IsPublished: true`, `HaveAudio: true`, and a populated `YouTubeVideoId` plus podcast platform links.
- Do not invent data. If a fact cannot be verified from the user input or public sources, leave the field blank instead of guessing.

## Dates and slugs

- `PartitionKey` must match the JSON object key.
- `RowKey` is the scheduled or recorded date in `yyyyMMdd` numeric form.
- `DateTimeUTC` must be a full ISO-8601 UTC timestamp.
- `DateTimeAsString` should stay in the existing format, for example `05/12/2026, 11:30:00 AM`.
- If the user gives a local date and time without a timezone, ask for the timezone before writing `DateTimeUTC`.
- Reuse the established slug when an episode already exists. For repeat guests, follow the existing pattern such as `paige-bailey-2`.

## Hugo wiring

- `content/guests.md` contains the `guests_refs` list used by the guest taxonomy pages.
- When staging a new guest, append the slug to `content/guests.md`.
- Individual guest pages are generated from the `guests_refs` taxonomy and `data/guests.json`.
- Audio URLs are derived from the slug and served from `https://podcasts.coffeeandopensource.com/interviews/{PartitionKey}.mp3`.

## Publish workflow

- The GitHub Action trigger is the commit message format `PUBLISH|guest-slug`.
- Recent repository history confirms the second segment is the guest slug, not a full URL.
- When publishing, stage only the intended files. Do not commit unrelated worktree changes.
- If the user asks to publish, commit with the exact `PUBLISH|guest-slug` format and push only if they explicitly want the workflow triggered immediately or are already working on `main`.

## Research expectations

- When staging a guest, prefer official sources for bios and profile links.
- Good sources include the guest's personal site, GitHub profile, LinkedIn profile, Bluesky, X, conference speaker pages, and employer bio pages.
- Keep the bio concise and factual.
- Prefer the guest's primary public profile for `GuestHandle`.
