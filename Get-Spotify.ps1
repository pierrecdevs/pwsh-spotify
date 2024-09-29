function Invoke-WebServer
{
    $httpListener = New-Object System.Net.HttpListener
    $httpListener.Prefixes.Add('http://localhost/callback/')

    $httpListener.Start()
    $context = $httpListener.GetContext()
    $context.Response.StatusCode = 200
    $context.Response.ContentType = 'application/json'
    $json = @{
        status = 200
        message = 'OK'
    } | ConvertTo-Json

    $encoding = [Text.Encoding]::UTF8.GetBytes($json)
    $context.Response.OutputStream.Write($encoding, 0, $enconding.Length)
    $context.Response.Close()
    return $httpListener
}

function Open-AuthorizationUrl
{
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string] $ClientId,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
        [string] $ClientSecret,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=2)]
        [string] $RedirectUri,
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=3)]
        [string] $Scope
    )

    Start-Process "https://accounts.spotify.com/authorize?response_type=code&client_id=${ClientId}&scope=${Scope}&&redirect_uri=${RedirectUri}"
}

function Get-AccessToken
{

    Param (
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string] $ClientId,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
        [string] $ClientSecret,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=2)]
        [string] $RedirectUri,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=3)]
        [string] $Code
    )

    $ClientBytes = [System.Text.Encoding]::UTF8.GetBytes("${ClientId}:${ClientSecret}")
    $EncodedClientInfo =[Convert]::ToBase64String($ClientBytes)

    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
        "Accept" = "application/json"
        "Authorization" = "Basic  ${EncodedClientInfo}"
    }

    $body = @{
        "grant_type" = "authorization_code"
        "code" = $Code
        "redirect_uri" = $RedirectUri
    }

    $uri = 'https://accounts.spotify.com/api/token'

    return Invoke-WebRequest -UseBasicParsing -Headers $headers -Method 'POST' -Body $body $uri
}

function Get-RefreshToken
{
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string] $ClientId,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
        [string] $ClientSecret,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=2)]
        [string] $RedirectUri,

        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=3)]
        [string] $Code
    )

    $ClientBytes = [System.Text.Encoding]::UTF8.GetBytes("${ClientId}:${ClientSecret}")
    $EncodedClientInfo =[Convert]::ToBase64String($ClientBytes)

    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
        "Accept" = "application/json"
        "Authorization" = "Basic  ${EncodedClientInfo}"
    }

    $body = @{
        "grant_type" = "refresh_token"
        "refresh_token" = $Code
        "redirect_uri" = $RedirectUri
    }

    $uri = 'https://accounts.spotify.com/api/token'

    return Invoke-WebRequest -UseBasicParsing -Headers $headers -Method 'POST' -Body $body $uri
}

function Get-CurrentSong
{
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string] $Token
    )

    $headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "Authorization" = "Bearer  ${Token}"
    }

    $uri = 'https://api.spotify.com/v1/me/player/currently-playing'

    return Invoke-WebRequest -UseBasicParsing -Headers $headers -Method 'GET' $uri
}

