[CmdletBinding()]
param(
    [datetime]$PublishedAfter,
    [string]$TitleContains,
    [string]$ApiKey,
    [string]$ChannelId,
    [int]$MaxResults = 10,
    [switch]$FirstOnly
)

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = $env:YOUTUBE_API_KEY
}

if ([string]::IsNullOrWhiteSpace($ChannelId)) {
    $ChannelId = $env:YOUTUBE_CHANNEL_ID
}

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw "Provide -ApiKey or set YOUTUBE_API_KEY."
}

if ([string]::IsNullOrWhiteSpace($ChannelId)) {
    throw "Provide -ChannelId or set YOUTUBE_CHANNEL_ID."
}

$query = @{
    part = "snippet"
    channelId = $ChannelId
    type = "video"
    order = "date"
    maxResults = $MaxResults
    key = $ApiKey
}

if ($PublishedAfter) {
    $query.publishedAfter = $PublishedAfter.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

$pairs = foreach ($entry in $query.GetEnumerator()) {
    "{0}={1}" -f $entry.Key, [uri]::EscapeDataString([string]$entry.Value)
}

$uri = "https://www.googleapis.com/youtube/v3/search?{0}" -f ($pairs -join "&")
$response = Invoke-RestMethod -Method Get -Uri $uri

$videos = foreach ($item in $response.items) {
    [pscustomobject]@{
        VideoId = $item.id.videoId
        Title = $item.snippet.title
        PublishedAt = $item.snippet.publishedAt
        Url = "https://www.youtube.com/watch?v=$($item.id.videoId)"
    }
}

if (-not [string]::IsNullOrWhiteSpace($TitleContains)) {
    $videos = $videos | Where-Object { $_.Title -like "*$TitleContains*" }
}

if ($FirstOnly) {
    $videos | Select-Object -First 1 | ConvertTo-Json
    return
}

$videos | ConvertTo-Json