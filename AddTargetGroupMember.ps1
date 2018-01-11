Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,
   
   [Parameter(Mandatory=$True)]
   [string]$targetGroup
)

$sqlServer = $sqlServer + ".database.windows.net"

$sqlCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$adminSqlServer = Get-AutomationVariable -Name 'SqlServerName'
$adminDatabase = Get-AutomationVariable -Name 'SqlServerDatabase'

$connectionString = "Data Source=" + $adminSqlServer + ";Initial Catalog=ElasticJobs;User ID=" + $sqlCredential.UserName + ";Password=" + $sqlCredential.GetNetworkCredential().Password + ";Connection Timeout=90;"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$query = "IF NOT EXISTS(SELECT * FROM jobs.target_group_members where target_type = 'SqlDatabase' and [database_name] = '" + $database + "' and target_group_name = '" + $targetGroup + "') EXEC jobs.sp_add_target_group_member @target_group_name = '" + $targetGroup + "', @target_type = 'SqlDatabase', @database_name = '" + $database + "', @server_name = '" + $sqlServer + "'"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)

$currentRetry = 0
$RetryDelay = 5
$MaxRetries = 3
$success = $false

do {
    try
    {
		if ($connection.State -eq 'Closed')
		{
    		$connection.Open()			
		}
		
		
		$command.ExecuteNonQuery() | Out-Null
		$connection.Close()
		
        $success = $true
    }
    catch [System.Exception]
    {
        $currentRetry = $currentRetry + 1
        
        if ($currentRetry -gt $MaxRetries) {                
            throw "Could not add database $database to target group $targetGroup. The error: " + $_.Exception.ToString()
        }
        
		Start-Sleep -s $RetryDelay
    }
} while (!$success);