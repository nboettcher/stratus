param 
    ( 
        [parameter(Mandatory=$True)]  
        [String]  
        $tenantId,  

        [parameter(Mandatory=$True)] 
        [String] 
        $adminEmailAddress, 
 
        [parameter(Mandatory=$True)] 
        [String] 
        $adminFirstName, 
 
        [parameter(Mandatory=$True)] 
        [String] 
        $adminLastName,

        [parameter(Mandatory=$True)] 
        [String] 
        $idp,

        [parameter(Mandatory=$True)] 
        [String] 
        $idpUserId
    ) 

$adminName = $adminFirstName + ' ' + $adminLastName

$sqlCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$adminSqlServer = Get-AutomationVariable -Name 'SqlServerName'
$adminDatabase = Get-AutomationVariable -Name 'SqlServerDatabase'

$sqlServer = ''
$database = ''
	
#get database name
$connectionString = "Data Source=" + $adminSqlServer + ";Initial Catalog=" + $adminDatabase + ";User ID=" + $sqlCredential.UserName + ";Password=" + $sqlCredential.GetNetworkCredential().Password + ";Connection Timeout=90"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$query = "SELECT DatabaseName, Server FROM Tenants WHERE TenantId = '" + $tenantId + "';"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
$reader = $command.ExecuteReader()
while ($reader.Read()){
    $database = $reader.GetValue(0)
    $sqlServer = $reader.GetValue(1)
}
$connection.Close()

$sqlServer = $sqlServer -replace '.database.windows.net', ''

Write-Output $database
Write-Output $sqlServer

#create admin user in AAD 
[guid]$userId = .\CreateAADUser.ps1 -firstName $adminFirstName -lastName $adminLastName -email $adminEmailAddress -idp $idp -idpUserId $idpUserId

#add admin user to user tenant mapping
.\CreateUserTenantMappingEntry.ps1 -TenantId $tenantId -UserId $userId	-email $adminEmailAddress -idp $idp -idpUserId $idpUserId

#add admin user to AdmUsers and assign to Administrators group
.\AddUserAsAdministrator.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -UserId $userId -Email $adminEmailAddress -Name $adminName -idp $idp -idpUserId $idpUserId