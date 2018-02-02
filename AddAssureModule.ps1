Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,

   [Parameter(Mandatory=$True)]
   [string]$product
)

$productsArray = $product.Split(';')

[bool]$businessProcess = $False

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

if ($productsArray -contains 'AX7')
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

if ($productsArray -contains 'NAV')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureNAV.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureNAV'
}

if ($productsArray -contains 'GP')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureGP.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureGP'
    $businessProcess = $True
}

if ($productsArray -contains 'AX')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureAX.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureAX'
    $businessProcess = $True
}

if ($productsArray -contains 'AC')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureAcumatica.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureAcumatica'
    $businessProcess = $True    
}

if ($productsArray -contains 'SAPB1')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureSAPB1.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureSAPB1'
}

if ($productsArray -contains 'PS')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssurePeoplesoft.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssurePeoplesoft'
    $businessProcess = $True        
}

if ($productsArray -contains 'ORFC')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureOracleFC.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureOracleFC'
    $businessProcess = $True        
}

if ($productsArray -contains 'JDE')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureJDEdwards.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureJDEdwards'
    $businessProcess = $True        
}

if ($businessProcess -eq $True)
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'AssureBusinessProcess.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'AssureBusinessProcesses'
}