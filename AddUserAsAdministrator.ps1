param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,
   
   [Parameter(Mandatory=$True)]
   [string]$userId,
   
   [Parameter(Mandatory=$True)]
   [string]$email,
   
   [Parameter(Mandatory=$True)]
   [string]$name
)

$sqlServer = $sqlServer + '.database.windows.net'

$sqlCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$connectionString = "Data Source=" + $sqlServer + ";Initial Catalog=" + $database + ";User ID=" + $sqlCredential.UserName + ";Password=" + $sqlCredential.GetNetworkCredential().Password + ";Connection Timeout=90"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$query = "INSERT INTO AdmUsers (UserID, UserLogonName, Domain, Email, Active) VALUES ('" + $userId + "', '" + $name + "', 'fpstratus.onmicrosoft.com', '" + $email + "', 1)"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
[void]$command.ExecuteNonQuery()
$connection.Close()

$query = "INSERT INTO AdmUserGroup (UserID, GroupID) VALUES ('" + $userId + "', (SELECT GroupID FROM AdmGroups WHERE Name = 'Administrators'))"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
[void]$command.ExecuteNonQuery()
$connection.Close()