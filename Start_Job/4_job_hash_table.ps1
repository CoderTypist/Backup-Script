
$places = @{ 'United States' = 'Washington D.C.'; France = 'Paris'; Venezuela = 'Caracas' }

Start-Job -name "HashJob" -ScriptBlock {

    $hash = $args[0]
    $hash['United States']

} -ArgumentList $places > $null

Wait-Job -name "HashJob" > $null
Receive-Job -name "HashJob"
