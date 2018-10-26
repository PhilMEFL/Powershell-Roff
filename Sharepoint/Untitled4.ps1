Get-SPWebApplication -IncludeCentralAdministration | Select -Expand Sites | ? ServerRelativeUrl -eq "/" | ?{
    Write-Host "Processing " $_
    get-spweb $_
}