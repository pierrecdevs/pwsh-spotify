# Spotify PowerShell Module

A PowerShell module to interact with Spotify API.

## Functions:
- `Initialize-SpotifyClient`: This will initialize the SpotifyClient
- `Invoke-WebServer`: Start a web server to receive authorization codes from Spotify. (admin permissions may be required)
- `Open-AuthorizationUrl`: Opens a browser to authorize your app with Spotify.
- `Get-AccessToken`: Retrieves an access token from Spotify.
- `Get-RefreshToken`: Retrieves a refreshed token from Spotify.
- `Get-CurrentSong`: Retrieves the currently playing song from Spotify.

## Usage:
1. Import the module:
    ```powershell
    Import-Module ./SpotifyModule/SpotifyModule.psm1
    ```
2. Initialize a SpotifyClient
    ```powershell
    PS C:\tools\pwsh\spotify-now-playing> Initialize-SpotifyClient -ClientId 'YOUR CLIENT ID' -ClientSecret 'YOUR CLIENT SECRET' -RedirectUri 'YOUR REDIRECT URL'
    ```
    **Note** You may not have a redirect url and that's fine, you just need the *code* that you get when you authorize the application.
3. Authorize the application
    ```powershell
    PS C:\tools\pwsh\spotify-now-playing>Open-AuthorizationUrl -Scope 'user-read-currently-playing,user-read-recently-played'
    ```
    This will open your browser to authorize the application. 
    
    **Note 1** If you do not authorize none of the features will work.

    **Note 2** You can technically spin up a tiny webserver to receive the code just add the `-InternalServer $true`
4. Once you authorize the application, you'll be redirected to the **redirect url** or the internal server.
5. Get an access token and refresh token by calling the following functions
 ```powershell
    PS C:\tools\pwsh\spotify-now-playing>Get-AccessToken -Code 'CODE YOU RECEIVED'
   ```
6. Get a long lived refresh token 
```powershell
    PS C:\tools\pwsh\spotify-now-playing>Get-RerfreshToken
```
7. Now you can use the various functions such as getting the current song.
```powershell
    PS C:\tools\pwsh\spotify-now-playing> $song = Get-CurrentSong
    PS C:\tools\pwsh\spotify-now-playing> $artist = $song.item.artists[0].name
    PS C:\tools\pwsh\spotify-now-playing> $title = $song.item.name
    PS C:\tools\pwsh\spotify-now-playing> Write-Host "Currently Spotify is playing: ${title} by ${artist}"
