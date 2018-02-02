Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,
   
   [Parameter(Mandatory=$True)]
   [string]$fileName,
   
   [Parameter(Mandatory=$False)]
   [string]$fpadminUser
)

$sqlServer = $sqlServer + ".database.windows.net"
$vsoCredential = Get-AutomationPSCredential -Name 'VSOCredentials'

$basicAuth = ("{0}:{1}" -f $vsoCredential.UserName,$vsoCredential.GetNetworkCredential().Password)
$basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
$basicAuth = [System.Convert]::ToBase64String($basicAuth)
$headers = @{Authorization=("Basic {0}" -f $basicAuth)}

$tfsUri = Get-AutomationVariable -Name "VSOUri"
$tfsUri = $tfsUri -replace "{filename}", $fileName
$createDatabase = Invoke-RestMethod -Uri $tfsUri -headers $headers -Method Get

if ($fpadminUser)
{
	$createDatabase = $createDatabase -replace 'userreplace', $fpadminUser
}

$sqlCredential = Get-AutomationPSCredential -Name 'SQLCredentials'
$connectionString = "Data Source=" + $sqlServer + ";Initial Catalog=" + $database + ";User ID=" + $sqlCredential.UserName + ";Password=" + $sqlCredential.GetNetworkCredential().Password + ";Connection Timeout=90;"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
$query = $createDatabase
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
            throw "Could not execute script $fileName. The error: " + $_.Exception.ToString()
        }
        
		Start-Sleep -s $RetryDelay
    }
} while (!$success);