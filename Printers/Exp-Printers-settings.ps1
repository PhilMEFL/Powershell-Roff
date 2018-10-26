﻿$ErrorActionPreference = 'Inquire'
# Constants definitions
#New-Variable outFolder '\\s-ci-mgtj01\LSA\_Scripts\martiqh\printer\export_data' -Option Constant
New-Variable outFolder 'c:\logs' -Option Constant
New-Variable ExcludedDrivers 'HP DeskJet 1120C;Oce VarioPrint 2110 PS;HP LaserJet 1200 Series PCL 6;HP LaserJet 8150 PCL 6;HP Officejet Pro K550 Series;HP Business Inkjet 2200/2250;RISO RZ 9 Series;HP Color LaserJet 4550 PCL 6HP DesignJet 1055CM by HP;HP Color LaserJet 8550 PCL 5C;HP 2500C Series;HP Color LaserJet 9500 PCL 6;HP DeskJet 1220C Printer;HP Color LaserJet 5550 PCL 6;HP Designjet T1100ps 44in HPGL2;HP Deskjet 9800 Series;HP Designjet Z6100 60in Photo HPGL2;LANIER LD145 PCL 6;Oce VarioPrint 2100 PS;HP Business Inkjet 2800 PS' -Option Constant
# Printer attributes pre Windows 2003
New-Variable Queued 1 -Option Constant
New-Variable Direct 2 -Option Constant
New-Variable Default 4 -Option Constant
New-Variable Shared 8 -Option Constant
New-Variable Network 16 -Option Constant
New-Variable Hidden 32 -Option Constant
New-Variable Local 64 -Option Constant
New-Variable EnableVQ 128 -Option Constant
New-Variable KeepPrintedJobs 256 -Option Constant
New-Variable DoCompleteFirst 512 -Option Constant
New-Variable WorkOffline 1024 -Option Constant
New-Variable EnableBIDI 2048 -Option Constant
New-Variable RawOnly 4096 -Option Constant
New-Variable Published 8192 -Option Constant

#"\\s-ci-mgtj01\LSA\_Scripts\martiqh\printer.ps\export_data"
# Script Variables definitions
$global:prnList = ""
$global:drvList = ""

# Hash tables creation for the IP adresses and ports
$hashIP = @{}
$hashPort = @{}

$attributes = @{1 = 'Queued';
			    2 = 'Direct';
			    4 = 'Default';
			    8 = 'Shared';
			   16 = 'Network';
			   32 = 'Hidden';
			   64 = 'Local';
			  128 = 'EnableVQ';
			  256 = 'KeepPrintedJobs';
			  512 = 'DoCompleteFirst';
			 1024 = 'Work Offline';
			 2048 = 'Enable BiDi';
			 4096 = 'Raw Only';
			 8192 = 'Published'}

# Functions
function Get-Ports($fromServer) {
	$arrReturn = @()

	$regHKLM = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(“LOCALMACHINE”,$fromServer)

	# Get Standard TCP/IP ports
	$regKey = $regHKLM.OpenSubKey(“System\CurrentControlSet\Control\Print\Monitors\Standard TCP/IP Port\Ports”)
	
	foreach ($key in $regKey.GetSubKeyNames()) {
		$arrReturn += $regKey.OpenSubKey($key)
		}

	# Get HP Standard TCP/IP ports
	$regKey = $regHKLM.OpenSubKey(“System\CurrentControlSet\Control\Print\Monitors\HP Standard TCP/IP Port\Ports”)
	
	foreach ($key in $regKey.GetSubKeyNames()) {
		$arrReturn += $regKey.OpenSubKey($key)
		}

	$arrReturn
	}

		# Get printer defaults
#		$regHKLM = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(“LOCALMACHINE”,$fromServer)
#		$regKey = $regHKLM.OpenSubKey(“System\CurrentControlSet\Control\Print\Printers”)
#		$printerData = $regkey.OpenSubKey($printer.Name)
#		$printerData.Name
		
		# Get printer data
#		$driverData = $printerData.OpenSubKey('printerDriverData')
#		$driverData.Name




function Get-Printers($fromServer) {
	$arrReturn = @()

	$regHKLM = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(“LOCALMACHINE”,$fromServer)
	$regKey = $regHKLM.OpenSubKey(“System\CurrentControlSet\Control\Print\Printers”)
	foreach ($key in $regKey.GetSubKeyNames()) {
		$temp = $regKey.OpenSubKey($key) 
		if ($temp.get_ValueCount() -gt 1) {
			$errorHandler = $ErrorActionPreference
			$ErrorActionPreference = 'Continue'
			$arrRow = '' | select $($temp.GetValueNames())
			$ErrorActionPreference = $errorHandler
			$arrRow.Name = $key
			foreach ($item in $temp.getValueNames()) {
				$arrRow.$item = $temp.getValue($item)
				}
			$arrReturn += $arrRow
			}
		else {
#			"Incomplete registry key for printer $key" | Out-File $logFile -Append
			}
		}
	$arrReturn
	}
	
function set-DriverType($Driver) {
	[string] $PrnType = "UNKNOWN"
	
	if ($Driver.ToUpper().Contains('LASERJET') -or 
		$Driver.ToUpper().Contains('HP UNIVERSAL PRINTING')) {
			$PrnType = 'HP'
			}	
	if ($Driver.ToUpper().Contains('NRG') -or
		$Driver.ToUpper().Contains('LANIER') -or
		$Driver.ToUpper().Contains('RICOH')) {
			$PrnType = 'COPIER'
			}		
	if ($Driver.ToUpper().Contains('XEROX') -or
		$Driver.ToUpper().Contains('INKJET') -or
		$Driver.ToUpper().Contains('COLOR') -or
		$Driver.ToUpper().Contains('NRG MP C2500')) {
			$PrnType = 'COLOUR'
			}
	if	($Driver.ToUpper().Contains('LEXMARK')) {
			$PrnType = 'LEX'
			}
	$PrnType
	}
		
function set-Driver($printer) {
	$Driver = $printer.'Printer Driver'

	# Set the right driver
	if ($Driver.ToUpper().Contains('LASERJET') -or
		$Driver.ToUpper().Contains('HP')) {
		$Driver = 'HP Universal Printing PCL 6 (v5.1)'
		}
	if ($Driver.ToUpper().Contains('LEXMARK')) {
		if ($printer.Description.Toupper().Contains('T644')) {
			$Driver = 'Lexmark T644 PS3'
			}
		else {
			$Driver = 'Lexmark Universal PS3'
			}
		}
# for Windows 2008 servers
#	if ($Driver.ToUpper().Contains('NRG') -or 
#		$Driver.ToUpper().Contains('RICOH')) {
#		$Driver = 'PS Driver for Universal Print'
#		}
	$Driver
	}

function set-NewPrinterName($Comment,$Driver) {
	[bool] $prnExist = $True
	[int] $i = 1
	[string] $tmpName = ""
	
	$Comment = $Comment.Split(",")

	$tmpName = "P-$($Comment[0].toUpper()).$($Comment[1].ToUpper()).$($Comment[2].ToUpper()).$(set-DriverType($Driver))"
	# avoid duplicate names
	while ($global:prnList.contains($tmpName)) {
		$temp = $tmpName.split('.')
		if ($i -eq 1) {
			$temp += [string] $i++
			}
		else {
			$temp[4] = [string] $i++
			}
		$tmpName = "$($temp[0]).$($temp[1]).$($temp[2]).$($temp[3]).$($temp[4])"
		}
	$global:prnList += "$tmpName;"
	$tmpName
	}
	
function set-NewLocation($Location,$Comment) {
	$Location = $Location.split('/')
	$Comment = $Comment.split(',')
	$DG = $Location[2].ToUpper() -replace('ADMIN','HR')
	$NewLocation = "$($Location[0].ToUpper())/$($Location[1].ToUpper())/$($DG)/$($Location[3].ToUpper())/$($Comment[2].ToUpper())"
	$NewLocation
	}
	
function set-NewComment($printer) {
	$printer.'Printer Driver' = $printer.'Printer Driver'.Replace(' PCL6','')
	$printer.'Printer Driver' = $printer.'Printer Driver'.Replace(' PCL 6','')
	$printer.'Printer Driver' = $printer.'Printer Driver'.Replace(' PCL 5','')
	$printer.'Printer Driver' = $printer.'Printer Driver'.Replace(' PS3','')
	$printer.'Printer Driver' = $printer.'Printer Driver'.Replace(' PS','')
	$printer.Location = $printer.Location.SubString(4)
	if ($printer.Description.toUpper().Contains('02DI')) {
		$printer.Description = "INV:$($printer.Description.substring($printer.Description.toUpper().indexof('02DI'),$printer.Description.Length - $printer.Description.ToUpper().IndexOf('02DI')))"
		}
	else {
		$printer.Description = 'INV:02DIxxxxxxxxxxx'
		}
	$NewComment = "$($printer.'Printer Driver') - $($printer.Location) - $($printer.Description)".toUpper()
#	$NewComment += " - Old name : $($printer.name)"
	$NewComment -replace('ADMIN','HR')
	}
	
function move-printer($prnNew, $server, $printerData, $driverData) {
	
	$server = $prnNew.NewServer
	
	# Create port
#	$port = Get-WmiObject -Query "select * from Win32_TCPIPPrinterPort where name = '$($prnNew.Port)'" -ComputerName $server
	$port = ([WMICLASS]"\\$server\ROOT\cimv2:Win32_TCPIPPrinterPort").createInstance()
#	if ($port) {
		# Update existing port
#		$PutType
#		$toto = @{Name=$prnNew.Port;SNMPEnabled=$false;Protocol='1';HostAddress=$prnNew.IPAddress;$port.PortNumber=$prnNew.IPPort}
#		Set-WmiInstance -class Win32_TCPIPPrinterPort -argument @{Name=$prnNew.Port;SNMPEnabled=$false;Protocol='1';HostAddress=$prnNew.IPAddress;$port.PortNumber=$prnNew.IPPort} -ComputerName $server -PutType UpdateOnly
#		}
	$port.Name = $prnNew.Port
	$port.SNMPEnabled = $false 
	$port.Protocol = 1 
	$port.HostAddress = $prnNew.IPAddress 
	$port.PortNumber = $prnNew.IPPort
	$port.Put() | Out-Null

#	# Add driver if needed
#	$drivers = get-wmiobject -class "Win32_PrinterDriver" -namespace "root\CIMV2" -computername $server 
#	foreach ($driver in $drivers) {
#		if ($Driver.name -eq $prnNew.'Printer Driver') {
#			"$($driver.name) already exists" | Out-Host
#			}
#		else {
#			"$($driver.name) will be added" | Out-Host
#			return
#			}
#		}

	$print = Get-WmiObject -Query "select * from Win32_Printer where name = '$($prnNew.Name)'" -ComputerName $server
#	$print = ([WMICLASS]"\\$server\ROOT\cimv2:Win32_Printer").createInstance() 
	$print.Name = $prnNew.Name
	$print.drivername = $prnNew.'Printer Driver'

	$print.Shared = $prnNew.Attributes -band $Shared
	$print.Published = $prnNew.Attributes -band $Published
	
	$print.Comment = $prnNew.Description
	$print.DeviceID = $prnNew.Name
	$print.Location = $prnNew.Location
	$print.PortName = $prnNew.Port
	$print.Shared = $true
	$print.Sharename = $prnNew.Name
	$print.'Separator File' = $prnNew.'Separator File'
	$print.Put() | Out-Null

#	$regHKLM = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(“LOCALMACHINE”,$Server)
#	$regKey = $regHKLM.OpenSubKey(“System\CurrentControlSet\Control\Print\Printers”,$true)
#	$regKey.GetSubKeyNames()
	
#	$regKey.CreateSubKey($prnNew.Name)
	}

function Get-PrinterData($printer) {

	$items = $printer | get-member -MemberType NoteProperty | select name

	$printerNew = @{}
	foreach ($item in $items) {
		$printerNew.add($item.Name,$printer.$($item.Name))
		}
	$printerNew.add('IPAddress','')
	$printerNew.add('IPPort','')
	$printerNew.add('NewServer','s-ci-prt03')

	# Generate new printer name (Comment and location are used to build the new name)
	# Check description and location
	if (($printer.Description) -and ($printer.Location))  {
		if ($printer.Description.Split(',').length -lt 3) {
			do {
				$printer.Description += ',**'
				}
			until ($printer.Description.Split(',').length -eq 3)
			}
		# Check if DG = HR or ADMIN and replace it by HR
		$DG = $printer.Location.Split('/')
		if ($DG.Length -gt 2) {
			if (($DG[2] -eq 'HR') -or ($DG[2] -eq 'ADMIN')) {
				$printer.Location = $printer.Location -replace('ADMIN','HR')
				if ($printer.Location.split('/').Length -lt 4) {
					do {
						$printer.Location += '/**'
						}
					until ($printer.Location.split('/').Length -eq 4)
					}
				}
			else {
				$printerNew.NewServer = 's-ci-prt01'
				}
			}
		else {
			$printerNew.NewServer = 's-ci-prt01'
			}
		}
	else {
		$printerNew.NewServer = 's-ci-prt01'
		}
		
	# Check driver
	
	$printerNew.'Printer Driver' = set-Driver($printer)
	if (($ExcludedDrivers.Contains($printerNew.'Printer Driver')) -or 
		($(set-DriverType($printer.'Printer Driver')) -eq 'UNKNOWN')) {
		$printerNew.NewServer = 's-ci-prt01'
		}
	
	if ($printerNew.NewServer -eq 's-ci-prt03') {
		$printerNew.Name = set-NewPrinterName $printer.Description $printer.'Printer Driver'
		$printerNew.Location = set-NewLocation $printer.Location $printer.Description
		$printerNew.Description = set-NewComment $printer
		# Checking PortName 
		if (!($printer.Name.Contains($printer.Port))) {
#			"Warning !!! The portname of $($oldName) is incorrect : $($printer.Port)" | Out-File $logFile -Append
			}	
		
		# Retrieve the IP address and port
		$Port = $printer.port
		if ($Port) {
			$printerNew.Port = $printerNew.Name
			$printerNew.IPAddress = $hashIP[$Port]
			$printerNew.IPPort = $hashPort[$Port]
			}
			
		"$fromServer\$($printer.Name) ==> $($printerNew.NewServer)\$($printerNew.Name) ($($printerNew['Printer Driver']))" | Out-Host
		}

	$printerNew
	}

#########################################################################################################
# Script entry point
#########################################################################################################

cls

# Check command line arguments
if ($args.count -ne 1) {
	"Usage : exp-Printers From_Server_Name"
	}
else {
	$fromServer = $args[0]

# Create output files
#	$outPath = "$outFolder\$fromServer"
#	if (!(Test-Path $outPath)) {
#		New-Item $outPath -type directory 
#		}	
#	else {
#		Remove-Item $outPath\*.* -Recurse -Force
#		}
#	$csvFile = "$outPath\itic-allprinters.csv"
#	$logFile = "$OutPath\itic-allprinters.log"
#	"New name,Description,Location,Driver,Separator file,Port,IP Address,IP Port,Old Name" | Out-File $csvFile
		
# Get Operating system of the server
	$OS = Get-WmiObject -class Win32_OperatingSystem -computername $fromServer
	$oldOS = ($OS.Version.Substring(0,3) -eq "5.0")

# Get printers ports
	# Windows 2000 Server doesn't handle WmiObject Win32_TCPIPPrinterPort
	if ($oldOS) {
		$printPorts = Get-Ports $fromServer
		}
	else {
		$printPorts = Get-WmiObject Win32_TCPIPPrinterPort -computer $fromServer
		}

	foreach ($printPort in $printPorts) {
		$portName = $printPort.Name.Substring($printPort.Name.LastIndexOf('\') + 1)
		if (!($hashIP[$portName])) {
			$hashIP.Add($portName,$printPort.GetValue('IPAddress'))
			}
		if (!($hashPort[$portName])) {
			$hashPort.Add($portName,$printPort.GetValue('PortNumber'))
			}
		}
	
# Get the printers on the server	
	# Windows 2000 Server doesn't handle WmiObject Win32_TCPIPPrinterPort
	if ($oldOS) {
		$printers = Get-Printers $fromServer
		foreach ($printer in $printers) {
			"select * from Win32_PrinterConfiguration where name = '$($printer.Name)'"
			$prnConf = get-wmiobject -Query "select * from Win32_PrinterConfiguration where name = '$($printer.Name)'" -computer $fromServer 
			}
		}
	else {
		$printers = get-wmiobject win32_printer -computer $fromServer 
		}
	
	$ix = 1
	foreach ($printer in $printers) {
		$oldName = $printer.Name
		"Handling printer #$ix of $($printers.count) : $oldName"

		# Move printer to the right server
		$prnNew = Get-PrinterData $printer
		if ($prnNew['NewServer'] -eq 's-ci-prt03') {
#			"$($prnNew['Name']),$($prnNew['Description']),$($prnNew['Location']),$($prnNew['Printer Driver']),$($prnNew['SeparatorFile']),$($prnNew['Port']),$($prnNew['IPAddress']),$($prnNew['IPPort']),$($oldName)" | Out-File $csvFile -Append
			move-printer $prnNew
			}
		else {
#			"$($prnNew.Name),$($prnNew.Description),$($prnNew.Location),$($prnNew.'Printer Driver'),$($printer.SeparatorFile),$($prnNew.Port),$($prnNew.IPAddress),$($prnNew.IPPort)" | Out-File $logFile -Append
			}
		$ix++
		}
	'Script completed'	
	}
