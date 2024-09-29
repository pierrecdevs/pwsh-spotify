# SpotifyModule.psm1
Import-Module -Force "$PSScriptRoot\SpotifyClient.psm1"

$global:spotifyClient = $null

<#
.SYNOPSIS
Initializes a SpotifyClient Class

.DESCRIPTION
This initializes the [SpotifyClient]::new

.PARAMETER ClientId
ClientId of your application you created

.PARAMETER ClientSecret
ClientSecret of your application you created

.PARAMETER RedirectUri
RedirectUrl you registered with your app

.EXAMPLE
Initialize-SpotifyClient -ClientId 'fakeidhere' -ClientSecret 'fakesecrethere' -RedirectUri 'http://localhost/callback/'

.NOTES
I would suggest using `http://localhost/callback/` as the RedirectUri unless you know what you're doing. 
#>
function Initialize-SpotifyClient {
    Param(
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$RedirectUri
    )

    if (-not $global:spotifyClient) {
        $global:spotifyClient = Get-SpotifyClient -ClientId $ClientId -ClientSecret $ClientSecret -RedirectUri $RedirectUri
        Write-Host 'Spotify Client Initialized'
    }
    else {
        Write-Host 'Spotify Client already initialized.'
    }
}

<#
.SYNOPSIS
Initializes a webserver **admin rights may be required.**

.DESCRIPTION
This will initialize an HttpWebServer used for the authentication process.. It's tiny, and blocking.

.PARAMETER Path
The path to listen to i.e: http://localhost/callback/ MUST END WITH A /

.EXAMPLE
Invoke-WebServer -Path '/callback/'

.NOTES
Administrator rights may be required. It's a blocking so you'll need two scripts.
#>
function Invoke-WebServer {
    Param(
        [string] $Path
    )
    
    if (-not $global:spotifyClient) {
        Write-Error 'SpotifyClient not initialized. Please call Initialize-SpotifyClient first.'
        return
    }

    return $global:spotifyClient.InvokeWebServer($path)
}

<#
.SYNOPSIS
Opens the authorization URL to authorize the application

.DESCRIPTION
This launchges whatever handles your `http:// ` to the authorization URL where you'll need to accept the permissions

.PARAMETER Scope
The scope you require for your client.

.PARAMETER InternalServer
This will invoke an internalserver to capture the code (untested....sorry?)

.EXAMPLE
Open-AuthorizedUrl -Scope user-read-currently-playing,user-read-recently-played
or
Open-AuthorizedUrl -Scope user-read-currently-playing,user-read-recently-played -InternalServer $true

.NOTES
Ther -InternalServer is a blocking option.
#>
function Open-AuthorizationUrl {
    Param(
        [string] $Scope,
        [bool] $InternalServer
    )

    if (-not $global:spotifyClient) {
        Write-Error 'SpotifyClient not initialized. Please call Initialize-SpotifyClient first.'
        return
    }

    $global:spotifyClient.OpenAuthorizationUrl($Scope, $InternalServer)
}

<#
.SYNOPSIS
With the code you received from the `Open-AuthorizationUrl` let's get a short-lived refresh and access token

.DESCRIPTION
This will trade a code for a short lived access and refresh token

.PARAMETER Code
Code is received by `Open-AuthorizationUrl`

.EXAMPLE
Get-AccessToken -Code 'code you received here'

.NOTES
This will a hashmap of following

- access_token 
- token_type
- expires_in
- refresh_token
- scope
#>
function Get-AccessToken {
    Param(
        [string] $Code
    )

    if (-not $global:spotifyClient) {
        Write-Error 'SpotifyClient not initialized. Please call Initialize-SpotifyClient first.'
        return
    }

    $result = $spotifyClient.GetAccessToken($Code)

    return $result
}

<#
.SYNOPSIS
Refreshes your token for a longer lived token


.DESCRIPTION
Refreshes your token for a longer lived token, if it fails you'll received an error
Most likely just have to get a new token, you may have unauthorized, or changed app settings

.EXAMPLE
Get-RefreshToken

.NOTES
Nothing needs to be passed as the internal SpotifyClient caches our tokens
It does however return:

- access_token
- token_type
- expires_in
- scope
#>
function Get-RefreshToken {

    if (-not $global:spotifyClient) {
        Write-Error 'SpotifyClient not initialized. Please call Initialize-SpotifyClient first.'
        return
    }

    $spotifyClient.GetRefreshToken()
    return $spotifyClient.AccessToken
}

<#
.SYNOPSIS
Retrieves the current playing song.

.DESCRIPTION
Retrieves the current playing song in a hashmap.
Lots of parsing but the main root options are

actions                NoteProperty System.Management.Automation.PSCustomObject actions=@{disallows=}
context                NoteProperty System.Management.Automation.PSCustomObject context=@{external_urls=; href=https://api.spotify.com/v1/playlists/37i9dQZF1DWXnscMH24yOc; type=playlist; uri=spotify:playlist:37i9dQZF1DWXnscMH24yOc}
currently_playing_type NoteProperty string currently_playing_type=track
is_playing             NoteProperty bool is_playing=True
item                   NoteProperty System.Management.Automation.PSCustomObject item=@{album=; artists=System.Object[]; available_markets=System.Object[]; disc_number=1; duration_ms=282744; explicit=False; external_ids=; external_urls=; href=https://api.spotify.com/v1/tracks/5aynOMgD0cXpcq8MJXkWjH; id=5aynOMgD0cXpcq8MJXkWjH; is_local=False; name=The Scientist; pop…
progress_ms            NoteProperty long progress_ms=34800
timestamp              NoteProperty long timestamp=1727642741814

.EXAMPLE
$song = Get-CurrentSong
$artist = $song.item.artists[0].name
$title = $song.item.name
Write-Host "Currently Spotify is playing: ${title} by ${artist}"

.NOTES
It's best to look at the Spotify Documentation on what the data received is
#>
function Get-CurrentSong {
    if (-not $global:spotifyClient) {
        Write-Error 'SpotifyClient not initialized. Please call Initialize-SpotifyClient first.'
        return
    }

    return $spotifyClient.GetCurrentSong()
}

# Export the functions for terminal use
Export-ModuleMember -Function Initialize-SpotifyClient, Invoke-WebServer, Open-AuthorizationUrl, Get-AccessToken, Get-RefreshToken, Get-CurrentSong