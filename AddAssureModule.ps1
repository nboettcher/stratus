Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,

   [Parameter(Mandatory=$True)]
   [string]$product
)

$productsArray = $product.Split(';')

[bool]$businessProcess = $True

.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'Assure.sql'
.\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'Assure'

if ($productsArray -contains 'NS')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureNetSuite.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureNetSuite'
    $businessProcess = $False
}

if ($productsArray -contains 'SF')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureSalesforce.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureSalesforce'
    $businessProcess = $False
}

if ($productsArray -contains 'INT')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureIntacct.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureIntacct'
    $businessProcess = $False
}

if ($productsArray -contains 'NAV')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureNAV.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureNAV'
    $businessProcess = $False    
}

if ($productsArray -contains 'SAPB1')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureSAPB1.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureSAPB1'
    $businessProcess = $False    
}

if ($productsArray -contains 'OR')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureOracle.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureOracle'
}

if ($productsArray -contains 'AX7')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureAX7.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureAX7'
}

if ($productsArray -contains 'SAP')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureSAP.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureSAP'
}

if ($productsArray -contains 'GP')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureGP.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureGP'
}

if ($productsArray -contains 'AX')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureAX.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureAX'
}

if ($productsArray -contains 'AC')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureAcumatica.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureAcumatica'
}

if ($productsArray -contains 'PS')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssurePeoplesoft.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssurePeoplesoft'
}

if ($productsArray -contains 'ORFC')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureOracleFC.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureOracleFC'
}

if ($productsArray -contains 'JDE')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureJDEdwards.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureJDEdwards'
}

if ($businessProcess -eq $True)
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureBusinessProcess.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureBusinessProcesses'
}