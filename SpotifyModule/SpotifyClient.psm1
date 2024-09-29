# SpotifyClient.psm1
Class SpotifyClient
{
    [string] $ClientId
    [string] $ClientSecret
    [string] $RedirectUri
    [string] $AccessToken
    [string] $RefreshToken

    SpotifyClient ([string]$ClientId, [string]$ClientSecret, [string]$RedirectUri)
    {
        $this.ClientId = $ClientId
        $this.ClientSecret = $ClientSecret
        $this.RedirectUri = $RedirectUri
    }

    # Method to open the authorization URL in a browser
    [void] OpenAuthorizationUrl ([string]$Scope, [bool] $internalServer)
    {
        if ($internalServer -eq $true) {
            $this.RedirectUri = 'http://localhost/callback/'
            $this.InvokeWebServer('http://localhost/callback/')
        }

        Write-Host "Redirect: $($this.ClientId)"
        Start-Process "https://accounts.spotify.com/authorize?response_type=code&client_id=$($this.ClientId)&scope=$($Scope)&redirect_uri=$($this.RedirectUri)"
    }

    # Method to start the web server to listen for the Spotify callback
    [System.Net.HttpListener] InvokeWebServer ([string] $path)
    {
        if ([string]::IsNullOrEmpty($path)) {
            return null
        }
    
        $httpListener = New-Object System.Net.HttpListener
        $httpListener.Prefixes.Add($path)
        $httpListener.Start()
        $context = $httpListener.GetContext()
        $context.Response.StatusCode = 200
        $context.Response.ContentType = 'application/json'
        $json = @{ status = 200; message = 'OK' } | ConvertTo-Json
        $encoding = [Text.Encoding]::UTF8.GetBytes($json)
        $context.Response.OutputStream.Write($encoding, 0, $encoding.Length)
        $context.Response.Close()
        return $httpListener
    }

    # Method to get an access token using the authorization code
    [pscustomobject] GetAccessToken ([string]$Code)
    {
        $ClientBytes = [System.Text.Encoding]::UTF8.GetBytes("$($this.ClientId):$($this.ClientSecret)")
        $EncodedClientInfo = [Convert]::ToBase64String($ClientBytes)

        $headers = @{
            'Content-Type'  = 'application/x-www-form-urlencoded'
            'Accept'        = 'application/json'
            'Authorization' = "Basic $EncodedClientInfo"
        }

        $body = @{
            'grant_type'   = 'authorization_code'
            'code'         = $Code
            'redirect_uri' = $this.RedirectUri
        }

        $uri = 'https://accounts.spotify.com/api/token'
        $response = Invoke-WebRequest -UseBasicParsing -Headers $headers -Method 'POST' -Body $body -Uri $uri
        $json = $response.Content | ConvertFrom-Json

        $this.AccessToken = $json.access_token
        $this.RefreshToken = $json.refresh_token
        return $json
    }

    # Method to refresh the access token using the refresh token
    [pscustomobject] GetRefreshToken ()
    {
        $ClientBytes = [System.Text.Encoding]::UTF8.GetBytes("$($this.ClientId):$($this.ClientSecret)")
        $EncodedClientInfo = [Convert]::ToBase64String($ClientBytes)

        $headers = @{
            'Content-Type'  = 'application/x-www-form-urlencoded'
            'Accept'        = 'application/json'
            'Authorization' = "Basic $EncodedClientInfo"
        }

        $body = @{
            'grant_type'    = 'refresh_token'
            'refresh_token' = $this.RefreshToken
            'redirect_uri'  = $this.RedirectUri
        }

        $uri = 'https://accounts.spotify.com/api/token'
        $response = Invoke-WebRequest -UseBasicParsing -Headers $headers -Method 'POST' -Body $body -Uri $uri
        $json = $response.Content | ConvertFrom-Json

        $this.AccessToken = $json.access_token
        return $json
    }

    # Method to get the current song playing on Spotify
    [pscustomobject] GetCurrentSong ()
    {
        $headers = @{
            'Content-Type'  = 'application/json'
            'Accept'        = 'application/json'
            'Authorization' = "Bearer $($this.AccessToken)"
        }

        $uri = 'https://api.spotify.com/v1/me/player/currently-playing'
        $response = Invoke-WebRequest -UseBasicParsing -Headers $headers -Method 'GET' -Uri $uri
        return $response.Content | ConvertFrom-Json
    }
}

<#
.SYNOPSIS
Instatiates a new SpotifyClient class

.DESCRIPTION
This exposes the class for use with other modules

.PARAMETER ClientId
ClientId of your application you created

.PARAMETER ClientSecret
ClientSecret of your application you created

.PARAMETER RedirectUri
RedirectUrl you registered with your app

.EXAMPLE
$spotifyClient = Get-SpotifyClient -ClientId 'fakeidhere' -ClientSecret 'fakesecrethere' -RedirectUri 'http://localhost/callback/'

#>
function Get-SpotifyClient([string]$ClientId, [string]$ClientSecret, [string]$RedirectUri) {
    return [SpotifyClient]::new($ClientId, $ClientSecret, $RedirectUri)
}

Export-ModuleMember -Function Get-SpotifyClient