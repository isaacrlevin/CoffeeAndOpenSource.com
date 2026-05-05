[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GuestSlug,

    [string]$ContainerName = "interviews",
    [string]$StorageAccountName,
    [string]$BaseUrl = "https://podcasts.coffeeandopensource.com",
    [switch]$UseConnectedAccount
)

$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$fileSearch = Get-ChildItem -Path $desktopPath -Filter "$GuestSlug*" -ErrorAction Stop | Select-Object -First 1

if ($null -eq $fileSearch) {
    throw "No file matching '$GuestSlug*' found on desktop at $desktopPath"
}

$resolvedFile = $fileSearch

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI ('az') is required but was not found on PATH."
}

$BlobName = $resolvedFile.Name

$connectionString = "DefaultEndpointsProtocol=https;AccountName=coffeeandopensource;AccountKey=TM/9QZNN5gCW92pwBjzHpro/KRLzoACI8suf26IFGbX2SNTKJMUxS8uMu4TzGnqJSmLvWYdPY7/k2AqLABMAOQ==;EndpointSuffix=core.windows.net"

if ([string]::IsNullOrWhiteSpace($StorageAccountName)) {
    $StorageAccountName = "coffeeandopensource"
}

$uploadArgs = @(
    "storage", "blob", "upload",
    "--overwrite", "true",
    "--only-show-errors",
    "--container-name", $ContainerName,
    "--name", $BlobName,
    "--file", $resolvedFile.FullName,
    "--content-type", "audio/mpeg"
)

if (-not [string]::IsNullOrWhiteSpace($connectionString)) {
    $uploadArgs += @("--connection-string", $connectionString)
} elseif (-not [string]::IsNullOrWhiteSpace($StorageAccountName)) {
    $uploadArgs += @("--account-name", $StorageAccountName, "--auth-mode", "login")
} elseif ($UseConnectedAccount) {
    throw "-UseConnectedAccount requires -StorageAccountName or AZURE_STORAGE_ACCOUNT_NAME."
} else {
    throw "Provide AZURE_STORAGE_CONNECTION_STRING or set AZURE_STORAGE_ACCOUNT_NAME and sign in with 'az login'."
}

$null = & az @uploadArgs

if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI upload failed."
}

$result = [pscustomobject]@{
    GuestSlug = $GuestSlug
    FilePath = $resolvedFile.FullName
    ContainerName = $ContainerName
    BlobName = $BlobName
    PublicUrl = ("{0}/{1}/{2}" -f $BaseUrl.TrimEnd('/'), $ContainerName, $BlobName)
}

$result | ConvertTo-Json
