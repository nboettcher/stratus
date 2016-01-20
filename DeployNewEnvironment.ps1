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

#create database 
.\CreateSQLDatabase.ps1 –SQLSERVER $sqlServer -Database $database -poolName $poolName
.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -FileName "Core.sql"

#execute scripts to deploy db objects
if ($modules -contains 'Assure')
{
	.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "Assure.sql"
		
	if ($product -contains 'NS')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "AssureNetSuite.sql"
	}
	
	if ($product -contains 'INT')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName "AssureIntacct.sql"
	}
}

.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -FileName "Cleanup.sql"
	
#create fpadmin user
[System.Management.Automation.PSCredential]$fpadminCredential = .\CreateFPAdminUser.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -EnvironmentName $environmentName

#tenant table entry
[guid]$tenantId = .\CreateTenantEntry.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -EnvironmentName $environmentName -CustomerId $accountId -FPAdminCredential $fpadminCredential	

#create admin user in AAD 
[guid]$userId = .\CreateAADUser.ps1 -firstName $adminFirstName -lastName $adminLastName -email $adminEmailAddress

#add admin user to user tenant mapping
.\CreateUserTenantMappingEntry.ps1 -TenantId $tenantId -UserId $userId	

#add admin user to AdmUsers and assign to Administrators group
.\AddUserAsAdministrator.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -UserId $userId -Email $adminEmailAddress -Name $adminName

.\EmailEnvironmentSuccess.ps1 -toEmail $adminEmailAddress -name $adminName | Out-Null