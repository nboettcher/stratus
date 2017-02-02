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
.\CreateSQLDatabase.ps1 -SQLSERVER $sqlServer -Database $database -poolName $poolName
.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -FileName 'Core.sql'

#create fpadmin user
[System.Management.Automation.PSCredential]$fpadminCredential = .\CreateFPAdminUser.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -EnvironmentName $environmentName

[bool]$businessProcess = $False

#execute scripts to deploy db objects
if ($modulesArray -contains 'AS')
{
	.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'Assure.sql'
	.\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'Assure'

	if ($productsArray -contains 'NS')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureNetSuite.sql'
	    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureNetSuite'
	}
	
	if ($productsArray -contains 'SF')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureSalesforce.sql'
	    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureSalesforce'
	}
	
	if ($productsArray -contains 'INT')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureIntacct.sql'
	    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureIntacct'
	}
	
	if ($productsArray -contains 'OR')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureOracle.sql'
    	.\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureOracle'
		$businessProcess = $True
	}
	
	if ($productsArray -contains 'AX')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureAX7.sql'
	    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureAX7'
		$businessProcess = $True
	}
	
	if ($productsArray -contains 'SAP')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureSAP.sql'
	    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureSAP'
		$businessProcess = $True
	}
	
	if ($businessProcess -eq $True)
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureBusinessProcess.sql'
	    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureBusinessProcesses'
	}
}

if ($modulesArray -contains 'AT')
{		
	if ($productsArray -contains 'NS')
	{
        .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrail.sql'
	    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrail'

		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailNetSuite.sql'
	    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailNetSuite'
	}

    if ($productsArray -contains 'AX')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailAX7.sql'
	    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailAX7'
		$businessProcess = $True
	}
}

if ($modulesArray -contains 'IM')
{
	.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'IdentityManager.sql'
	.\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'IdentityManager'
		
	if ($productsArray -contains 'NS')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'IdentityManagerNetSuite.sql'
    	.\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'IdentityManagerNetSuite'
	}

	if ($productsArray -contains 'SAP')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'IdentityManagerSAP.sql'
    	.\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'IdentityManagerSAP'
	}

	if ($productsArray -contains 'AX')
	{
		.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'IdentityManagerAX7.sql'
    	.\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'IdentityManagerAX7'
    }
}

.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -FileName 'Cleanup.sql'

#tenant table entry
[guid]$tenantId = .\CreateTenantEntry.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -EnvironmentName $environmentName -CustomerId $accountId -FPAdminCredential $fpadminCredential	

#create admin user in AAD 
[guid]$userId = .\CreateAADUser.ps1 -firstName $adminFirstName -lastName $adminLastName -email $adminEmailAddress

#add admin user to user tenant mapping
.\CreateUserTenantMappingEntry.ps1 -TenantId $tenantId -UserId $userId	

#add admin user to AdmUsers and assign to Administrators group
.\AddUserAsAdministrator.ps1 -SQLSERVER $sqlServer -Database $database.tostring() -UserId $userId -Email $adminEmailAddress -Name $adminName

.\EmailEnvironmentSuccess.ps1 -toEmail $adminEmailAddress -environment $environmentName -name $adminName | Out-Null

return $tenantId