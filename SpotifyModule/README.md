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
2. Use the available functions to authenticate and interact with the Spotify API.

