
# Start-Job will not have access to the variables that you have in your current script
# -InputObject needs to be used to pass data to Start-Job
# Unfortunately, only one object can be passed to Start-Job

$name = "John Smith"
Start-Job -name "InputJob" -InputObject $name -ScriptBlock { $input } > $null
Wait-Job -name "InputJob" > $null
Receive-Job -name "InputJob"
