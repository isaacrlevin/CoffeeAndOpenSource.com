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

$connectionString = $env:AZURE_STORAGE_CONNECTION_STRING

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

if ([string]::IsNullOrWhiteSpace($connectionString)) {
    if (-not [string]::IsNullOrWhiteSpace($StorageAccountName)) {
        $uploadArgs += @("--account-name", $StorageAccountName, "--auth-mode", "login")
    } elseif ($UseConnectedAccount) {
        throw "-UseConnectedAccount requires AZURE_STORAGE_CONNECTION_STRING or -StorageAccountName with 'az login'."
    } else {
        throw "Set AZURE_STORAGE_CONNECTION_STRING environment variable or provide -StorageAccountName and sign in with 'az login'."
    }
} else {
    $uploadArgs += @("--connection-string", $connectionString)
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
