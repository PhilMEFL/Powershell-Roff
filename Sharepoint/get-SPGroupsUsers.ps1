if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin Microsoft.SharePoint.PowerShell
    }

 $site = New-Object Microsoft.SharePoint.SPSite('http://copsp01')
 $site.RootWeb.sitegroups | %{
        "Group: " + $_.name
        $_.users | %{
            "  User: " + $_.name
            }
        }


