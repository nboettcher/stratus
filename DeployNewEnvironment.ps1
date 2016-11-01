param 
    ( 
        [parameter(Mandatory=$True)]  
        [String]  
        $accountId,  
  
        [parameter(Mandatory=$True)]  
        [String]  
        $sqlServer,
		
		[parameter(Mandatory=$True)]  
        [String]  
        $poolName,
		
		[parameter(Mandatory=$True)] 
        [String] 
        $environmentName, 
		
		[parameter(Mandatory=$True)]
		[String]
		$product,
		
		[parameter(Mandatory=$True)]
		[String]
		$modules,
 
        [parameter(Mandatory=$True)] 
        [String] 
        $adminEmailAddress, 
 
        [parameter(Mandatory=$True)] 
        [String] 
        $adminFirstName, 
 
        [parameter(Mandatory=$True)] 
        [String] 
        $adminLastName
    ) 

$dbEnvironmentName = $environmentName -replace '\s',''
[string]$database = 'FPASSURE_' + $dbEnvironmentName
$adminName = $adminFirstName + ' ' + $adminLastName

$modulesArray = $modules.Split(';')
$productsArray = $product.Split(';')

#create database 
.\CreateSQLDatabase.ps1 –SQLSERVER $sqlServer -Database $database -poolName $poolName
.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -FileName "Core.sql"

#create fpadmin user
[System.Management.Automation.PSCredential]$fpadminCredential = .\CreateFPAdminUser.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -EnvironmentName $environmentName

[bool]$businessProcess = $False

#execute scripts to deploy db objects
if ($modulesArray -contains 'AS')
{
	.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "Assure.sql"
		
	if ($productsArray -contains 'NS')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "AssureNetSuite.sql"
	}
	
	if ($productsArray -contains 'SF')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "AssureSalesforce.sql"
	}
	
	if ($productsArray -contains 'INT')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "AssureIntacct.sql"
	}
	
	if ($productsArray -contains 'OR')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "AssureOracle.sql"
		$businessProcess = $True
	}
	
	if ($productsArray -contains 'AX')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureAX7.sql'
		$businessProcess = $True
	}
	
	if ($productsArray -contains 'SAP')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureSAP.sql'
		$businessProcess = $True
	}
	
	if ($businessProcess -eq $True)
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "AssureBusinessProcess.sql"
	}
}

if ($modulesArray -contains 'AT')
{
	.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "AuditTrail.sql"
		
	if ($productsArray -contains 'NS')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "AuditTrailNetSuite.sql"
	}
}

if ($modulesArray -contains 'IM')
{
	.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "IdentityManager.sql"
		
	if ($productsArray -contains 'NS')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "IdentityManagerNetSuite.sql"
	}

	if ($productsArray -contains 'SAP')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "IdentityManagerSAP.sql"
	}

	if ($productsArray -contains 'AX')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "IdentityManagerAX7.sql"
	}
}

.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -FileName "Cleanup.sql"

#tenant table entry
[guid]$tenantId = .\CreateTenantEntry.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -EnvironmentName $environmentName -CustomerId $accountId -FPAdminCredential $fpadminCredential	

#create admin user in AAD 
[guid]$userId = .\CreateAADUser.ps1 -firstName $adminFirstName -lastName $adminLastName -email $adminEmailAddress

#add admin user to user tenant mapping
.\CreateUserTenantMappingEntry.ps1 -TenantId $tenantId -UserId $userId	

#add admin user to AdmUsers and assign to Administrators group
.\AddUserAsAdministrator.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -UserId $userId -Email $adminEmailAddress -Name $adminName

.\EmailEnvironmentSuccess.ps1 -toEmail $adminEmailAddress -environment $environmentName -name $adminName | Out-Null