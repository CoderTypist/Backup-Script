
# author: Christian Bargraser
# https://github.com/CoderTypist


# Start-Job can only receive one object
# One possible work around is creating an array
# 
# For details regarding the passing of arrays to Start-Job
# please refer to 3_job_array.ps1
# 
# Another solution is to use a hash table
#
# Unfortunatley, a hash table passed to start-job does not behave as expected
# $input.keys yields nothing
# $input.values yields nothing
# $input[<key>] yields nothing
# 
# The solution I found was to pass an array of strings to Start-Job and
# then create a hash table from the values in the array.
# prehash() will create an array that can be turned back
# into a hash table at a later time
# The hashify() function in Start-Job will create a hash table from the array
# 
# By doing this, you can effectively pass multiple variables to Start-Job
# and reference them by name (via the hashtable)


# receives [hashtable]
# return [string[]]
function dehash([hashtable]$table){

    [string[]]$arr = @()
    foreach ( $key in $table.keys ) { $arr += [string]$key }
    foreach ( $value in $table.values ) { $arr += [string]$value }

    return $arr
}

$places = @{ 'United States' = 'Washington D.C.'; France = 'Paris'; Venezuela = 'Caracas' }
$places = dehash($places)

Start-Job -InputObject $places -name "HashJob" -ScriptBlock {

    function hashify($arr) {
        
        $arr = $arr.split("`n")
        $hash = @{}

        for ( $i = 0; $i -lt $arr.length/2 ; $i++ ) {

            $hash[$arr[$i]] = $arr[$i*2]
        }

        return $hash
    }

    $input = hashify($input)
    $input

} > $null

Wait-Job -name "HashJob" > $null
Receive-Job -name "HashJob"
