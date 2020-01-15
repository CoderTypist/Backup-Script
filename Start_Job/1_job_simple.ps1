
Start-Job -name "SimpleJob" -ScriptBlock { ls } > $null
Wait-Job -name "SimpleJob" > $null
Receive-Job -name "SimpleJob"
