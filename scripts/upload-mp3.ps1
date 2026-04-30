[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Mandatory = $true)]
    [string]$GuestSlug,

    [string]$ContainerName = "interviews",
    [string]$BlobName,
    [string]$StorageAccountName,
    [string]$BaseUrl = "https://podcasts.coffeeandopensource.com",
    [switch]$UseConnectedAccount
)

$resolvedFile = Resolve-Path -Path $FilePath -ErrorAction Stop

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI ('az') is required but was not found on PATH."
}

if ([string]::IsNullOrWhiteSpace($BlobName)) {
    $BlobName = "$GuestSlug.mp3"
}

$connectionString = $env:AZURE_STORAGE_CONNECTION_STRING

if ([string]::IsNullOrWhiteSpace($StorageAccountName)) {
    $StorageAccountName = $env:AZURE_STORAGE_ACCOUNT_NAME
}

$uploadArgs = @(
    "storage", "blob", "upload",
    "--overwrite", "true",
    "--only-show-errors",
    "--container-name", $ContainerName,
    "--name", $BlobName,
    "--file", $resolvedFile.Path,
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
    FilePath = $resolvedFile.Path
    ContainerName = $ContainerName
    BlobName = $BlobName
    PublicUrl = ("{0}/{1}/{2}" -f $BaseUrl.TrimEnd('/'), $ContainerName, $BlobName)
}

$result | ConvertTo-Json
