param(
   [Parameter(Mandatory=$True,Position=1)]
   [int]$length
)

function PassesComplexity($password)
{
    $upper = $password -cmatch '[A-Z]'
    if (-Not $upper) 
    {
        #Write-Host 'no upper'
        return $False
    }

    $lower = $password -cmatch '[a-z]'
    if (-Not $lower) 
    {
        #Write-Host 'no lower'
        return $False
    }

    $number = $password -cmatch '[0-9]'
    if (-Not $number) 
    {
        #Write-Host 'no number'
        return $False
    }

    #Write-Host 'passes'
    return $True
}

function GenerateRandomString() 
{
Param(

[int]$length=10,

[string[]]$sourcedata
)

For ($loop=1; $loop -le $length; $loop++) 
{
    $TempPassword+=($sourcedata | GET-RANDOM)
}

return $TempPassword
}

function GeneratePassword($length)
{
    $ascii=$NULL;
    For ($a=48;$a -le 57;$a++) 
    {
        $ascii+=,[char][byte]$a 
    }

    For ($a=65;$a -le 90;$a++) 
    {
        $ascii+=,[char][byte]$a 
    }

    For ($a=97;$a -le 122;$a++) 
    {
        $ascii+=,[char][byte]$a 
    }

    $password = GenerateRandomString -length $length -sourcedata $ascii

    Write-Output $password
}

$password = GeneratePassword($length)

While (-Not (PassesComplexity($password)))
{
    #Write-Host 'Complexity failed: ' $password
    $password = GeneratePassword($length)    
}

Write-Output $password