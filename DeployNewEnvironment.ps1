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
        $adminLastName,

        [parameter(Mandatory=$True)] 
        [String] 
        $idp,

		[parameter(Mandatory=$True)] 
        [String] 
        $idpUserId
    ) 

$dbEnvironmentName = $environmentName -replace '\s',''
[string]$database = 'FPASSURE_' + $dbEnvironmentName
$adminName = $adminFirstName + ' ' + $adminLastName

$modulesArray = $modules.Split(';')
$productsArray = $product.Split(';')

#create database 
.\CreateSQLDatabase.ps1 -SQLSERVER $sqlServer -Database $database -poolName $poolName
.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -FileName 'Core.sql'

#create fpadmin user
[System.Management.Automation.PSCredential]$fpadminCredential = .\CreateFPAdminUser.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -EnvironmentName $environmentName

#execute scripts to deploy db objects
if ($modulesArray -contains 'AS')
{
    .\AddAssureModule.ps1 -SQLSERVER $sqlServer -Database $database -product $product
}

if ($modulesArray -contains 'AT')
{	
    .\AddAuditTrailModule.ps1 -SQLSERVER $sqlServer -Database $database -product $product
}

if ($modulesArray -contains 'IM')
{
    .\AddIdentityManagerModule.ps1 -SQLSERVER $sqlServer -Database $database -product $product
}

if ($modulesArray -contains 'SD')
{
    .\AddSecurityDesignerModule.ps1 -SQLSERVER $sqlServer -Database $database -product $product
}

.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -FileName 'Certifications.sql'
.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -FileName 'Cleanup.sql'

#tenant table entry
[guid]$tenantId = .\CreateTenantEntry.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -EnvironmentName $environmentName -CustomerId $accountId -FPAdminCredential $fpadminCredential	

#create admin user in AAD 
[guid]$userId = .\CreateAADUser.ps1 -firstName $adminFirstName -lastName $adminLastName -email $adminEmailAddress -idp $idp -idpUserId $idpUserId

#add admin user to user tenant mapping
.\CreateUserTenantMappingEntry.ps1 -TenantId $tenantId -UserId $userId	-idp $idp -email $adminEmailAddress -idpUserId $idpUserId

#add admin user to AdmUsers and assign to Administrators group
.\AddUserAsAdministrator.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -UserId $userId -Email $adminEmailAddress -Name $adminName -idp $idp -idpUserId $idpUserId

$azureSubscription =  Get-AutomationVariable -Name 'AzureSubscription'

if ($azureSubscription -eq 'Fastpath-Stratus-Development' -or $azureSubscription -eq 'Fastpath-Stratus-Test')
{
    .\AddFastpathDEVS.ps1 -tenantId $tenantId
}

.\EmailEnvironmentSuccess.ps1 -toEmail $adminEmailAddress -environment $environmentName -name $adminName | Out-Null

return $tenantId