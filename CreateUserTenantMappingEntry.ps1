param(  
   [Parameter(Mandatory=$True)]
   [Guid]$tenantId,
   
   [Parameter(Mandatory=$True)]
   [Guid]$userId,

   [Parameter(Mandatory=$True)]
   [string]$idp,

   [Parameter(Mandatory=$True)]
   [string]$email,

   [Parameter(Mandatory=$True)]
   [string]$idpUserId
)

$sqlCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$sqlServer = Get-AutomationVariable -Name 'SqlServerName'
$database = Get-AutomationVariable -Name 'SqlServerDatabase'

$sqlCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$connectionString = "Data Source=" + $sqlServer + ";Initial Catalog=" + $database + ";User ID=" + $sqlCredential.UserName + ";Password=" + $sqlCredential.GetNetworkCredential().Password + ";Connection Timeout=90"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)

IF($userId.toString() -eq [system.guid]::empty)
{
    $id = [guid]::NewGuid()
    $query = "INSERT INTO InvitedUsers (Id, IdentityProvider, IdentityUserId, TenantId) VALUES ('" + $id + "', '" + $idp + "', '" + $idpUserId + "', '" + $tenantId + "')"
}
else
{
    $query = "INSERT INTO UserTenantMapping (TenantId, UserId) VALUES ('" + $tenantId + "', '" + $userId + "')"
}

$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
[void]$command.ExecuteNonQuery()
$connection.Close()