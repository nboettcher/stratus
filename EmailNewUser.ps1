Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$toEmail,
   
   [Parameter(Mandatory=$True)]
   [string]$userPassword,
   
   [Parameter(Mandatory=$True)]
   [string]$name
)

$sendGridCredential = Get-AutomationPSCredential -Name 'SendGridCredentials'
$username = $sendGridCredential.UserName
$password = $sendGridCredential.GetNetworkCredential().Password

$body = $name ", Welcome to Fastpath Assure. You have been granted access to Fastpath Assure. Your credentials are as follows: User: " + $toEmail + " Password: " + $userPassword + " Access Fastpath Assure now!"

$url = "https://api.sendgrid.com/api/mail.send.json"
$contentType = "application/x-www-form-urlencoded; charset=UTF-8"
$body = "api_user=" + $username + "&api_key=" + $password + "&to=" + $toEmail + "&subject=Welcome to Fastpath Assure&text=" + $body + "&from=noreply@fastpathassure.com"

$resp = Invoke-RestMethod -Method Post -Uri $url -ContentType $contentType -Body $body
Write-Output $resp