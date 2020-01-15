
# author: Christian Bargraser
# https://github.com/CoderTypist
# 
# Any new PowerShell console variables will be passed to Start-Job
# Any variables available in the current scope will be passed to Start-Job
# Any changes to automatic variables will not be passed to Start-Job

$gvar = @{}
Get-Variable | % { $gvar[$_.Name] = $_.Value }

Start-Job -name "NewVarJob" -scriptblock {

    $hash = $args[0]
    
    foreach ( $key in $hash.keys ) { 
        New-Variable $key $hash[$key] -ErrorAction "silentlycontinue"
    }

    Get-Variable

} -ArgumentList $gvar > $null

Wait-Job "NewVarJob" > $null
Receive-job "NewsVarJob"