Param(
  [Parameter(Mandatory=$True,Position=1)]
  [string]$sqlServer,
	
  [Parameter(Mandatory=$True)]
  [string]$database,
  
  [Parameter(Mandatory=$True)]
  [string]$poolName
)

$environmentName = $environmentName -replace '\s',''
$Cred = Get-AutomationPSCredential -name 'AutomationServiceAccount'
$login = Login-AzureRMAccount -Credential $Cred
$AzureSubscriptionId = Get-AutomationVariable -Name 'AzureSubscriptionId'
$account = Add-AzureRmAccount -SubscriptionId $AzureSubscriptionId  -Credential $Cred

$edition = Get-AutomationVariable -Name 'DatabaseEdition'
$level = Get-AutomationVariable -Name 'DatabaseLevel'
$resourceGroup = Get-AutomationVariable -Name 'ResourceGroup'

$newDatabase = New-AzureRMSqlDatabase -ResourceGroupName $resourceGroup -ServerName $sqlServer -DatabaseName $database -ElasticPoolName $poolName