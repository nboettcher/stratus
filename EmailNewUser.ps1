Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$toEmail,
   
   [Parameter(Mandatory=$True)]
   [string]$userPassword,
   
   [Parameter(Mandatory=$True)]
   [string]$name
)

$password = Get-AutomationVariable -Name 'SendGridAPIKey'
$url = Get-AutomationVariable -Name 'WebAppUrl'

$body = '{ "personalizations" : [ { "to": [ { "email": "' + $toEmail + '"}],"subject": "Welcome to Fastpath Assure", "substitutions" : { "%name%": "' + $name + '", "%user%": "' + $toEmail + '", "%password%": "' + $userPassword + '", "%url%": "' + $url + '" } } ], "from": { "email": "noreply@gofastpath.com" }, "template_id": "07f3a703-eb92-4c8f-8385-5eb215469383"}'


$url = "https://api.sendgrid.com/v3/mail/send"
$headers =  @{"Authorization"=("Bearer " + $password )}
$contentType = "application/json"

$resp = Invoke-RestMethod -Method Post -Uri $url -ContentType $contentType -Body $body -Headers $headers 
Write-Output $resp