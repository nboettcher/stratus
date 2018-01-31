Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sqlServer,
	
   [Parameter(Mandatory=$True)]
   [string]$database,

   [Parameter(Mandatory=$True)]
   [string]$product
)

$productsArray = $product.Split(';')

.\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'SecurityDesigner.sql'
.\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'SecurityDesigner'

if ($productsArray -contains 'AX7')
{
    .\ExecuteSQLScript.ps1 -SQLSERVER $sqlServer -Database $database -FileName 'SecurityDesignerAX7.sql'
    .\AddTargetGroupMember.ps1 -SQLSERVER $sqlServer -Database $database -TargetGroup 'SecurityDesignerAX7'
}