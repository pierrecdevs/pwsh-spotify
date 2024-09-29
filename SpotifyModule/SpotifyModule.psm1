# SpotifyModule.psm1
Import-Module -Force "$PSScriptRoot\SpotifyClient.psm1"

$global:spotifyClient = $null

function Initialize-SpotifyClient
{
    Param(
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$RedirectUri
    )

    if (-not $global:spotifyClient)
    {
        $global:spotifyClient = Get-SpotifyClient -ClientId $ClientId -ClientSecret $ClientSecret -RedirectUri $RedirectUri
        Write-Host "Spotify Client Initialized"
    } else
    {
        Write-Host "Spotify Client already initialized."
    }

}
function Invoke-WebServer
{
    Param(
        [string] $Path
    )
    
    if (-not $global:spotifyClient)
    {
        Write-Error "SpotifyClient not initialized. Please call Initialize-SpotifyClient first."
        return
    }

    return $global:spotifyClient.InvokeWebServer($path)
}

function Open-AuthorizationUrl
{
    Param(
        [string] $Scope,
        [bool] $internalServer
    )

    if (-not $global:spotifyClient)
    {
        Write-Error "SpotifyClient not initialized. Please call Initialize-SpotifyClient first."
        return
    }

    $global:spotifyClient.OpenAuthorizationUrl($Scope, $internalServer)
}

function Get-AccessToken
{
    Param(
        [string] $Code
    )

    if (-not $global:spotifyClient)
    {
        Write-Error "SpotifyClient not initialized. Please call Initialize-SpotifyClient first."
        return
    }

    $spotifyClient.GetAccessToken($Code)
    return $spotifyClient.RefreshToken
}

function Get-RefreshToken
{

    if (-not $global:spotifyClient)
    {
        Write-Error "SpotifyClient not initialized. Please call Initialize-SpotifyClient first."
        return
    }

    $spotifyClient.GetRefreshToken()
    return $spotifyClient.AccessToken
}

function Get-CurrentSong
{
    if (-not $global:spotifyClient)
    {
        Write-Error "SpotifyClient not initialized. Please call Initialize-SpotifyClient first."
        return
    }


    return $spotifyClient.GetCurrentSong()
}

# Export the functions for terminal use
Export-ModuleMember -Function Initialize-SpotifyClient, Invoke-WebServer, Open-AuthorizationUrl, Get-AccessToken, Get-RefreshToken, Get-CurrentSong

