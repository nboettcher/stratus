param(
	[object]$WebhookData
)

if ($WebhookData -ne $null) {   

        # Collect properties of WebhookData
        $WebhookName    =   $WebhookData.WebhookName
        $WebhookHeaders =   $WebhookData.RequestHeader
        $WebhookBody    =   $WebhookData.RequestBody

        # Collect individual headers. VMList converted from JSON.
        $From = $WebhookHeaders.From
        $environmentList = ConvertFrom-Json -InputObject $WebhookBody
        Write-Output "Runbook started from webhook $WebhookName by $From."

        # Start each virtual machine
        foreach ($env in $environmentList)
        {
            $EnvName = $env.environmentName
            Write-Output "Deploying $EnvName"
				
			[guid]$tenantId = .\DeployNewEnvironment.ps1 -accountId $env.accountId -sqlServer $env.sqlServer -poolName $env.poolName -environmentName $env.environmentName -product $env.product -modules $env.modules -adminEmailAddress $env.adminEmailAddress -adminFirstName $env.adminFirstName -adminLastName $env.adminLastName -idp $env.idp -idpUserId $env.idpUserId
        }
    }