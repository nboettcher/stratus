[OutputType([System.Management.Automation.PSCredential])]

param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,
   
   [Parameter(Mandatory=$True)]
   [string]$environmentName	
)

$environmentName = $environmentName -replace '\s',''
$userName = "FPAdmin_" + $environmentName
$password = .\GenerateRandomPassword.ps1 -Length 15

#create user in database
$sqlCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$connectionString = "Data Source=" + $sqlServer + ".database.windows.net;Initial Catalog=" + $database + ";User ID=" + $sqlCredential.UserName + ";Password=" + $sqlCredential.GetNetworkCredential().Password + ";Connection Timeout=90"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$query = "CREATE USER " + $userName + " WITH password='" + $password + "';"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
[void]$command.ExecuteNonQuery()
$connection.Close()

#run grant script
.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "GrantFPAdmin.sql" -fpadminUser $userName

$password = $password | ConvertTo-SecureString -asPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential($userName, $password)

return $cred