
# author: Christian Bargraser
# https://github.com/CoderTypist
#
# Any new PowerShell console variables will be passed on to Start-Job
# Any variables available in the current scope will be passed on to Start-Job
# Any changes to automatic variables will be passed on to Start-Job
# 
# Some data type conversions that are unable to take place
# I skip over these manually with a switch

$gvar = @{}
Get-Variable | % { $gvar[$_.Name] = $_.Value }

Start-Job -name "SetVarJob" -scriptblock {

    $hash = $args[0]
    
    foreach ( $key in $hash.keys ) { 
        
        $skip = $false

        switch($key){
            "OutputEncoding" { $skip = $true; Break }
            "PSBoundParameters" { $skip = $true; Break }
            "MyInvocation" { $skip = $true; Break }
        }

        if ( $skip -eq $true ) { continue }

        Set-Variable $key $hash[$key] -ErrorAction "silentlycontinue"
    }

    Get-Variable

} -ArgumentList $gvar > $null

Wait-Job "SetVarJob" > $null
Receive-job "SetVarJob"