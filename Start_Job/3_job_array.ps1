
# author: Christian Bargraser
# https://github.com/CoderTypist


# Start-Job can only receive one object
# One possible work around is creating an array
# 
# An array passed to Start-Job does not behave as expected
#
# Without the call to split:
# - You cannot index $input
# - $input.length will return 1
#
# However, all the data is there
# The array just needsd to be "reconstructed"
# 
# I use split() in Start-Job to create an array from $input
# However, if the first item in the array received by Start-Job is not a String
# the call to split() will fail
# Calling stringify() will return an array of Strings
# 
# Even after doing all of this, you still need to index the array to access data
# This is inconvenient, as you need to remember what each index in the array contains
# If someone comes back to maintain the code a year later, it might not be clear
# what $input[0] represents
#
# This is why I use a hash table in 4_job_hash_table.ps1
# Readability is greatly improved when you can say:
# - $input["height"]
# Instead of:
# - $input[2]


# receives [object[]]
# returns [string[]]
function stringify([object[]]$list) {

    [string[]]$arr = @()
    foreach ( $item in $list ) { $arr += [string]$item }
    return $arr
}

$people = @()
$people += "Michael Scott"
$people += "Dwight Schrute"
$people += "Jim Halpert"
$people = stringify($people)

Start-Job -InputObject $people -name "ArrayJob" -ScriptBlock { 

    $input = $input.split("`n")

    foreach ( $item in $input ) { $item }

} > $null

Wait-Job -name "ArrayJob" > $null
Receive-Job -name "ArrayJob"
