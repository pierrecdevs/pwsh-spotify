. './Get-Spotify.ps1'

$ClientId = Read-Host "Client ID"
$ClientSecret = Read-Host "Client Secret"

$httpListener = Invoke-WebServer
Open-AuthorizationUrl -ClientId $ClientId -ClientSecret $ClientSecret -RedirectUri 'http://localhost/callback/' -Scope 'user-read-currently-playing,user-read-recently-played'

$httpListener.Close()

$Code = Read-Host "Please insert everything after 'http://localhost/callback/?code='"

$page = Get-AccessToken -ClientId $ClientId -ClientSecret $ClientSecret -RedirectUri 'http://localhost/callback/' -Code $Code
$json = $page.Content | ConvertFrom-Json

$page = Get-RefreshToken -ClientId $ClientId -ClientSecret $ClientSecret -RedirectUri 'http://localhost/callback/' -Code $json.refresh_token
$json = $page.Content | ConvertFrom-Json


$page = Get-CurrentSong -Token $json.access_token
$json = $page.Content | ConvertFrom-Json

if ([string]::IsNullOrEmpty($json))
{
    Write-Host "Nothing playing, or spotify not running."
} else
{
    Write-Host 'Current song'
    Write-Host $json
}
