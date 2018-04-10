Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,

   [Parameter(Mandatory=$True)]
   [string]$product
)

$productsArray = $product.Split(';')

.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrail.sql'
.\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrail'

if ($productsArray -contains 'NS')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailNetSuite.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailNetSuite'
}

if ($productsArray -contains 'AX7')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailAX7.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailAX7'
}

if ($productsArray -contains 'OR')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailOracle.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailOracle'
}

if ($productsArray -contains 'SAP')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailSAP.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailSAP'
}

if ($productsArray -contains 'NAV')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailNAV.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailNAV'
}

if ($productsArray -contains 'GP')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailGP.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailGP'
}

if ($productsArray -contains 'AX')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailAX.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailAX'
}

if ($productsArray -contains 'AX5')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailAX5.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailAX5'
}

if ($productsArray -contains 'SL')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AuditTrailSL.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AuditTrailSL'
}