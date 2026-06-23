# Stage a New Guest

Use this prompt when a new Coffee and Open Source episode is scheduled and needs to be staged in the site data.

## Inputs

- Guest name
- Scheduled local date and time
- Timezone
- Topic
- Any known profile URLs or handles

## Goal

Create a new unpublished guest entry in `data/guests.json` and append the guest slug to `content/guests.md`.

## Instructions

1. Build the guest slug from the guest name.
2. If the slug already exists for a previous appearance, follow the existing suffix pattern such as `-2`.
3. Research the guest using official public sources and collect:
   - a short factual bio
   - GitHub, LinkedIn, Bluesky, X, YouTube, blog, or other strong public links when available
4. Do not invent facts or URLs. Leave fields blank if you cannot verify them.
5. Add a new entry to `data/guests.json` using the repository schema and field order.
6. For a staged guest, set:
   - `IsPublished` to `false`
   - `YouTubeVideoId` to an empty string
   - `HaveAudio` to `false`
   - `SpotifyLink`, `AmazonLink`, and `APLink` to empty strings
7. Use the provided timezone to compute `DateTimeUTC`.
8. Set `RowKey` to the scheduled date in `yyyyMMdd` form.
9. Set `GuestHandle` to the strongest primary public profile or handle the guest uses.
10. Append the slug to the `guests_refs` list in `content/guests.md`.
11. Preserve the existing JSON style and ordering.
12. Show the diff when complete and stop unless the user explicitly asks for a commit.

## Output expectations

- Summarize what was added.
- Call out any fields left blank because they could not be verified.
