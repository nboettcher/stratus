Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$toEmail
)

$sendGridCredential = Get-AutomationPSCredential -Name 'SendGridCredentials'
$username = $sendGridCredential.UserName
$password = $sendGridCredential.GetNetworkCredential().Password

$url = "https://api.sendgrid.com/api/mail.send.json"
$contentType = "application/x-www-form-urlencoded; charset=UTF-8"
$body = "api_user=" + $username + "&api_key=" + $password + "&to=" + $toEmail + "&subject=Your new Fastpath Assure environment has been provisioned&text=Your new Fastpath Assure environment has been provisioned. If you are a new user to Fastpath Assure, you will be sent an email containg your login (your email address) and your temporary password. Go to www.fastpathassure.com to login.&from=noreply@fastpathassure.com"

$resp = Invoke-RestMethod -Method Post -Uri $url -ContentType $contentType -Body $body
Write-Output $resp