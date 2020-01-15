
$people = @("Michael Scott", "Dwight Schrute", "Jim Halpert")

Start-Job -name "ArrayJob" -ScriptBlock { 

    foreach ( $item in $args ) { $item }

} -ArgumentList $people > $null

Wait-Job -name "ArrayJob" > $null
Receive-Job -name "ArrayJob"
