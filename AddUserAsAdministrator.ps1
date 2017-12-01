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
   [string]$name,

   [Parameter(Mandatory=$True)]
   [string]$idp,

   [Parameter(Mandatory=$True)]
   [string]$idpUserId
)

$sqlServer = $sqlServer + '.database.windows.net'
$invited = "0";

IF($userId.toString() -eq [system.guid]::empty)
{
    $userId = [guid]::NewGuid()
    $invited = "1"
}

$name = $name -replace "'", "''"

$sqlCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$connectionString = "Data Source=" + $sqlServer + ";Initial Catalog=" + $database + ";User ID=" + $sqlCredential.UserName + ";Password=" + $sqlCredential.GetNetworkCredential().Password + ";Connection Timeout=90"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$query = "INSERT INTO AdmUsers (UserID, UserLogonName, Domain, Email, Active, Invited, IdentityUserID) VALUES ('" + $userId + "', '" + $name + "', '" + $idp + "', '" + $email + "', 1, " + $invited + ", '" + $idpUserId + "')"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
[void]$command.ExecuteNonQuery()
$connection.Close()

$query = "INSERT INTO AdmUserGroup (UserID, GroupID) VALUES ('" + $userId + "', (SELECT GroupID FROM AdmGroups WHERE Name = 'Administrators'))"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
[void]$command.ExecuteNonQuery()
$connection.Close()

$atInd = $email.IndexOf('@')
$domain = $email.Substring($atInd + 1, $email.Length - $atInd -1)

$query = "UPDATE FpConfiguration SET [Value] = '" + $domain + "' WHERE [Name] = 'UserDomainWhitelist'"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
[void]$command.ExecuteNonQuery()
$connection.Close()