param(
   [Parameter(Mandatory=$True)]
   [string]$firstName,
   
   [Parameter(Mandatory=$True)]
   [string]$lastName,
   
   [Parameter(Mandatory=$True)]
   [string]$email,
      
   [Parameter(Mandatory=$True)]
   [string]$idp,

   [Parameter(Mandatory=$True)]
   [string]$idpUserId
)

#Gather variables
$ClientID = Get-AutomationVariable -Name "AADB2CClientId"
$Secret = Get-AutomationVariable -Name "AADB2CClientSecret"
$AzureADDomain = Get-AutomationVariable -Name "AADB2CDomain"
$idpAttribute = Get-AutomationVariable -Name "AADB2CidpExtension"
$emailAttribute = Get-AutomationVariable -Name "AADB2CemailExtension"

#Build the token
$header = Get-AzureADToken -ClientID $ClientID -Secret $Secret -AzureADDomain $AzureADDomain

#check if user already exists, if it does, return object id
$getUser = Invoke-RestMethod -Uri "https://graph.windows.net/$AzureADDomain/users?`$filter=$idpAttribute eq '$idp' and $emailAttribute eq '$idpUserId'&api-version=1.6" -Method Get -Headers @{"Authorization"=$header;"Content-Type"="application/json";}

if ($getUser.Value)
{
    return $getUser.value.objectId
}

if ($idp -eq 'Local')
{
    $password = .\GenerateRandomPassword.ps1 -Length 10
    $fullName = $firstName + ' ' + $lastName
    $mailName = $firstName + $lastName
    $mailName = $mailName -replace '\s',''
	
    $body = @{
        "accountEnabled"= "true";
        "alternativeSignInNamesInfo" = @(           
            @{
                "type" = "emailAddress";            
                "value" = $email
            }
        );
        "creationType"="NameCoexistence";        
        "displayName"=$fullName;             
        "mailNickname"=$mailName;                     
        "passwordProfile" = @{
            "password"= $password;
            "forceChangePasswordNextLogin"="true"
        };
        "passwordPolicies"="DisablePasswordExpiration";
        "$idpAttribute"=$idp;
        "$emailAttribute"=$idpUserId;
    }

    $json = $body | ConvertTo-Json -depth 2
    $enc = New-Object "System.Text.ASCIIEncoding"
    $byteArray = $enc.GetBytes($json)
    $contentLength = $byteArray.Length

    $createdUser = Invoke-RestMethod -Uri "https://graph.windows.net/$AzureADDomain/users?api-version=beta" -Method Post -Body $json -Headers @{"Authorization"=$header;"Content-Type"="application/json";"Content-Length"=$contentLength}
    $emailNewUser = .\EmailNewUser.ps1 -toEmail $email -userPassword $password -name $fullName
    return $createdUser.objectId
}
else
{
    return [system.guid]::empty;
}