Param
(
    [Parameter (Mandatory= $false)]
    [string] $tenantId,
    [Parameter (Mandatory= $false)]    
    [object] $WebhookData
)

if ($WebhookData -ne $null) {   
        $WebhookBody = $WebhookData.RequestBody
        $Input = ConvertFrom-Json -InputObject $WebhookBody
        $tenantId = $Input.tenantId
    }

$tenantId = $tenantId.toLower()
$AzureSubscriptionId = Get-AutomationVariable -Name 'AzureSubscriptionId'
$adminSqlServer =  Get-AutomationVariable -Name 'SqlServerName'
$adminDatabase =  Get-AutomationVariable -Name 'SqlServerDatabase'
$resourceGroup = Get-AutomationVariable -Name 'ResourceGroup'

$database = ''
$sqlServer = ''

$adminCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$adminUserId = $adminCredential.UserName
$adminPassword = $adminCredential.GetNetworkCredential().Password

$adminCredential = Get-AutomationPSCredential -Name 'AutomationServiceAccount'

#connect to Azure Sub
$login = Login-AzureRmAccount -Credential $adminCredential
$account = Add-AzureRmAccount -SubscriptionId $AzureSubscriptionId  -Credential $adminCredential

Set-AzureRmContext -SubscriptionId $AzureSubscriptionId

#delete azure scheduler items
Get-AzureRmSchedulerJobCollection | Where-Object {$_.JobCollectionName -contains "*$tenantId*" } | Remove-AzureRmSchedulerJobCollection

#Define the storage account and context.
$StorageAccountName = Get-AutomationVariable -Name 'StorageAccountName'
$StorageAccountKey = Get-AutomationVariable -Name 'StorageAccountKey'
$Ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

#delete azure storage container
Remove-AzureStorageContainer -Name $tenantId -Context $Ctx -Force -ErrorAction SilentlyContinue

#delete azure storage table for Audit
$auditTenantId = $tenantId -replace '-', ''
Remove-AzureStorageTable -Name "Audit$auditTenantId" -Context $Ctx -Force -ErrorAction SilentlyContinue

#get database name
$connectionString = "Data Source=" + $adminSqlServer + ";Initial Catalog=" + $adminDatabase + ";User ID=" + $adminUserId + ";Password=" + $adminPassword + ";Connection Timeout=90"
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

#delete usertenantmapping
$connectionString = "Data Source=" + $adminSqlServer + ";Initial Catalog=" + $adminDatabase + ";User ID=" + $adminUserId + ";Password=" + $adminPassword + ";Connection Timeout=90"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$query = "DELETE FROM UserTenantMapping WHERE TenantId = '" + $tenantId + "';"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
[void]$command.ExecuteNonQuery()
$connection.Close()

#delete tenant entry
$connectionString = "Data Source=" + $adminSqlServer + ";Initial Catalog=" + $adminDatabase + ";User ID=" + $adminUserId + ";Password=" + $adminPassword + ";Connection Timeout=90"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$query = "DELETE FROM Tenants WHERE TenantId = '" + $tenantId + "';"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
[void]$command.ExecuteNonQuery()
$connection.Close()

#delete ElasticJobs target memberships
$connectionString = "Data Source=" + $adminSqlServer + ";Initial Catalog=ElasticJobs;User ID=" + $adminUserId + ";Password=" + $adminPassword + ";Connection Timeout=90"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$query = "SELECT target_group_name, target_id FROM jobs.target_group_members WHERE database_name = '" + $database + "';"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$connection.Open()
$reader = $command.ExecuteReader()
while ($reader.Read()){
    $target_group_name = $reader.GetValue(0)
    $target_id = $reader.GetValue(1)

    $deleteConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
    $deleteQuery = "EXEC jobs.sp_delete_target_group_member '" + $target_group_name + "', '" + $target_id + "'"
    $deleteCommand = New-Object -TypeName System.Data.SqlClient.SqlCommand($deleteQuery, $deleteConnection)
    $deleteConnection.Open()
    [VOID]$deleteCommand.ExecuteNonQuery()
    $deleteConnection.Close()
}
$connection.Close()

#delete database
Remove-AzureRmSqlDatabase -ResourceGroupName $resourceGroup -ServerName $sqlServer -DatabaseName $database -Force