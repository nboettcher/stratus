Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,

   [Parameter(Mandatory=$True)]
   [string]$product
)

$productsArray = $product.Split(';')

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

if ($productsArray -contains 'AX7')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'IdentityManagerAX7.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'IdentityManagerAX7'
}

if ($productsArray -contains 'OR')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'IdentityManagerOracle.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'IdentityManagerOracle'
}

if ($productsArray -contains 'NAV')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'IdentityManagerNAV.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'IdentityManagerNAV'
}

if ($productsArray -contains 'GP')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'IdentityManagerGP.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'IdentityManagerGP'
}

if ($productsArray -contains 'AX')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'IdentityManagerAX.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'IdentityManagerAX'
}