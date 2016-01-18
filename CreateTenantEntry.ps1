[OutputType([Guid])]

param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,
   
   [Parameter(Mandatory=$True)]
   [string]$environmentName,
   
   [Parameter(Mandatory=$True)]
   [Guid]$customerId,
   
   [Parameter(Mandatory=$True)]
   [System.Management.Automation.PSCredential]
   [System.Management.Automation.Credential()]$fpadminCredential
)

$sqlServer = $sqlServer + '.database.windows.net'
$tenantId = [guid]::NewGuid()
$fpadminPassword = $fpadminCredential.GetNetworkCredential().Password
$fpadminUser = $fpadminCredential.UserName

#encrypt fpadmin Password
$salt = Get-AutomationVariable 'FastpathSalt'
$encryptedPassword = Get-EncryptedText -Text $fpadminPassword -Password $customerId -Salt $salt

$sqlCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$adminSqlServer = Get-AutomationVariable -Name 'SqlServerName'
$adminDatabase = Get-AutomationVariable -Name 'SqlServerDatabase'

$connectionString = "Data Source=" + $adminSqlServer + ";Initial Catalog=" + $adminDatabase + ";User ID=" + $sqlCredential.UserName + ";Password=" + $sqlCredential.GetNetworkCredential().Password + ";Connection Timeout=90"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand("CreateTenant", $connection)
$command.CommandType = [System.Data.CommandType]'StoredProcedure'
$command.Parameters.AddWithValue("@TenantId", $tenantId) | Out-Null
$command.Parameters.AddWithValue("@CustomerId", $customerId) | Out-Null
$command.Parameters.AddWithValue("@Name", $environmentName) | Out-Null
$command.Parameters.AddWithValue("@Server", $sqlServer) | Out-Null
$command.Parameters.AddWithValue("@DatabaseName", $database) | Out-Null
$command.Parameters.AddWithValue("@User", $fpadminCredential.UserName.tostring()) | Out-Null
$command.Parameters.AddWithValue("@Password", $encryptedPassword) | Out-Null
$connection.Open()
$command.ExecuteNonQuery() | Out-Null
$connection.Close()

return $tenantId