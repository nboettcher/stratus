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
$template = Get-AutomationVariable -Name 'NewUserTemplate'

$body = '{ "personalizations" : [ { "to": [ { "email": "' + $toEmail + '"}],"subject": "Welcome to Fastpath Assure", "substitutions" : { "%name%": "' + $name + '", "%user%": "' + $toEmail + '", "%password%": "' + $userPassword + '", "%url%": "' + $url + '" } } ], "from": { "email": "noreply@gofastpath.com" }, "template_id": "' + $template + '"}'


$url = "https://api.sendgrid.com/v3/mail/send"
$headers =  @{"Authorization"=("Bearer " + $password )}
$contentType = "application/json"

$resp = Invoke-RestMethod -Method Post -Uri $url -ContentType $contentType -Body $body -Headers $headers 
Write-Output $resp