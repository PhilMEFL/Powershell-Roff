$filePath = "G:\DKV\WindowsPowerShell\shares.xml"
$xmlDoc = [xml](Get-Content $filePath)

$xmlDoc.Servers.Server | % {
	"{0} is {1} {2}" -f $_.Name ,$_.Status, $_.Shares.Name
	if ($_.Status -eq 'online') {
		$_.Shares.Name
		$gazou = $_.Shares.Permissions
		$gazou.Permission
		$gazou.User
		$gazou.GetType()
		
		$toto = ''
#		$_.Shares.SelectNodes('Permissions') | % {
#			for ($i = 0; $i -lt $_.user.count; $i++) {
#				$_.user[$i] + ": " + $_.permission[$i]
#				}
#			}
		}
	'---'
	}