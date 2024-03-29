#Just change the below parameters

$DirectoryToSaveTo='C:\temp'
$Filename='DatabaseDetails'
$From ='pjayaram@test.com'
$to = 'pjayaram@test.com'
$SMTP= 'abcd.defg.com'
$DSN='<DSNName>'

# constants.
$xlCenter=-4108
$xlTop=-4160
$xlOpenXMLWorkbook=[int]51
# and we put the queries in here

# You can replace the SQL

$SQL=@"
USE MASTER 
SELECT @@SERVERNAME Servername, 
CONVERT(VARCHAR(25), DB.name) AS dbName, 
CONVERT(VARCHAR(10), DATABASEPROPERTYEX(name, 'status')) AS [Status], 
(SELECT COUNT(1) FROM sysaltfiles WHERE DB_NAME(dbid) = DB.name AND groupid !=0 ) AS DataFiles, 
(SELECT SUM((size*8)/1024) FROM sysaltfiles WHERE DB_NAME(dbid) = DB.name AND groupid!=0) AS [Data MB], 
(SELECT COUNT(1) FROM sysaltfiles WHERE DB_NAME(dbid) = DB.name AND groupid=0) AS LogFiles, 
(SELECT SUM((size*8)/1024) FROM sysaltfiles WHERE DB_NAME(dbid) = DB.name AND groupid=0) AS [Log MB], 
(SELECT SUM((size*8)/1024) FROM sysaltfiles WHERE DB_NAME(dbid) = DB.name AND groupid!=0)+(SELECT SUM((size*8)/1024) FROM sysaltfiles WHERE DB_NAME(dbid) = DB.name AND groupid=0) TotalSizeMB, 
convert(sysname,DatabasePropertyEx(name,'Updateability'))  Updateability, 
convert(sysname,DatabasePropertyEx(name,'UserAccess')) UserAccess , 
convert(sysname,DatabasePropertyEx(name,'Recovery')) RecoveryModel , 
convert(sysname,DatabasePropertyEx(name,'Version')) Version , 
CASE cmptlevel 
WHEN 60 THEN '60 (SQL Server 6.0)' 
WHEN 65 THEN '65 (SQL Server 6.5)' 
WHEN 70 THEN '70 (SQL Server 7.0)' 
WHEN 80 THEN '80 (SQL Server 2000)' 
WHEN 90 THEN '90 (SQL Server 2005)' 
WHEN 100 THEN '100 (SQL Server 2008)' 
END AS [compatibility level], 
CONVERT(VARCHAR(20), crdate, 103) + ' ' + CONVERT(VARCHAR(20), crdate, 108) AS [Creation date], 
ISNULL((SELECT TOP 1 
CASE TYPE WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Differential' WHEN 'L' THEN 'Transaction log' END + ' – ' + 
LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(),Backup_finish_date))) + ' days ago', 'NEVER')) + ' – ' + 
CONVERT(VARCHAR(20), backup_start_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_start_date, 108) + ' – ' + 
CONVERT(VARCHAR(20), backup_finish_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_finish_date, 108) + 
' (' + CAST(DATEDIFF(second, BK.backup_start_date, 
BK.backup_finish_date) AS VARCHAR(4)) + ' '+ 'seconds)' 
FROM msdb.dbo.backupset BK WHERE BK.database_name = DB.name ORDER BY backup_set_id DESC),'-') AS [Last backup] 
FROM sysdatabases DB 
ORDER BY dbName, [Last backup] DESC, NAME
"@

#Create a Excel file to save the data
# if the directory doesn't exist, then create it

if (!(Test-Path -path "$DirectoryToSave")) #create it if not existing
  {
  New-Item "$DirectoryToSave" -type directory | out-null
  }

$excel = New-Object -Com Excel.Application #open a new instance of Excel
$excel.Visible = $True #make it visible (for debugging more than anything)
$wb = $Excel.Workbooks.Add() #create a workbook
$currentWorksheet=1 #there are three open worksheets you can fill up
      if ($currentWorksheet-lt 4) 
      {
        $ws = $wb.Worksheets.Item($currentWorksheet)
      }
      else  
      {
        $ws = $wb.Worksheets.Add()
      } #add if it doesn't exist
      $currentWorksheet += 1 #keep a tally
    
  # You can refresh it

      $qt = $ws.QueryTables.Add("ODBC;DSN=$DSN", $ws.Range("A1"), $SQL)
      # and execute it
      if ($qt.Refresh()) #if the routine works OK
            {
            $ws.Activate()
            $ws.Select()
            $excel.Rows.Item(1).HorizontalAlignment = $xlCenter
            $excel.Rows.Item(1).VerticalAlignment = $xlTop
            $excel.Rows.Item("1:1").Font.Name = "Calibri"
            $excel.Rows.Item("1:1").Font.Size = 11
            $excel.Rows.Item("1:1").Font.Bold = $true
            $Excel.Columns.Item(1).Font.Bold = $true
            }
     
$filename = "$DirectoryToSaveTo$filename.xlsx" #save it according to its title
if (test-path $filename ) { rm $filename } #delete the file if it already exists
$wb.SaveAs($filename,  $xlOpenXMLWorkbook) #save as an XML Workbook (xslx)
$wb.Saved = $True #flag it as being saved
$wb.Close() #close the document
$Excel.Quit() #and the instance of Excel
$wb = $Null #set all variables that point to Excel objects to null
$ws = $Null #makes sure Excel deflates
$Excel=$Null #let the air out

#Function to send email with an attachment

Function sendEmail([string]$emailFrom, [string]$emailTo, [string]$subject,[string]$body,[string]$smtpServer,[string]$filePath)
{
#initate message
$email = New-Object System.Net.Mail.MailMessage 
$email.From = $emailFrom
$email.To.Add($emailTo)
$email.Subject = $subject
$email.Body = $body
# initiate email attachment 
$emailAttach = New-Object System.Net.Mail.Attachment $filePath
$email.Attachments.Add($emailAttach) 
#initiate sending email 
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($email)
}

#Call Function 
sendEmail -emailFrom $from -emailTo $to  -subject "Database Details" -body "Database Information" -smtpServer $SMTP -filePath $filename


###################################################################################################################