param(
   [Parameter(Mandatory=$True)]
   [string]$firstName,
   
   [Parameter(Mandatory=$True)]
   [string]$lastName,
   
   [Parameter(Mandatory=$True)]
   [string]$email
)

#Gather variables
$ClientID = Get-AutomationVariable -Name "AADB2CClientId"
$Secret = Get-AutomationVariable -Name "AADB2CClientSecret"
$AzureADDomain = Get-AutomationVariable -Name "AADB2CDomain"

#Build the token
$header = Get-AzureADToken -ClientID $ClientID -Secret $Secret -AzureADDomain $AzureADDomain

#check if user already exists, if it does, return object id
$getUser = Invoke-RestMethod -Uri "https://graph.windows.net/fpstratus.onmicrosoft.com/users?`$filter=alternativeSignInNamesInfo/any(x:x/value eq '$email')&api-version=beta" -Method Get -Headers @{"Authorization"=$header;"Content-Type"="application/json";}

if ($getUser.Value)
{
    return $getUser.value.objectId
}

$password = .\GenerateRandomPassword.ps1 -Length 10
$fullName = $firstName + ' ' + $lastName
$mailName = $firstName + $lastName

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
}

$json = $body | ConvertTo-Json -depth 2
$enc = New-Object "System.Text.ASCIIEncoding"
$byteArray = $enc.GetBytes($json)
$contentLength = $byteArray.Length

$createdUser = Invoke-RestMethod -Uri "https://graph.windows.net/fpstratus.onmicrosoft.com/users?api-version=beta" -Method Post -Body $json -Headers @{"Authorization"=$header;"Content-Type"="application/json";"Content-Length"=$contentLength}
$emailNewUser = .\EmailNewUser.ps1 -toEmail $email -userPassword $password

return $createdUser.objectId


