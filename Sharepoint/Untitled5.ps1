$test = Get-SPWebApplication -IncludeCentralAdministration | ? IsAdministrationWebApplication | Select -Expand Sites | ? ServerRelativeUrl -eq "/" 
$test
$test | Get-SPWeb | Select -Expand SiteGroups | ? Name -eq "Farm Administrators" | Select -expand Users



SharePoint_AdminContent_5b4c880f-0a29-4c62-9949-82691b72830c