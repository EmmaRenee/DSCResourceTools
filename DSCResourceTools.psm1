# Get all functions in module
$functions = Get-ChildItem -Path "$PSScriptRoot\function" -Include "*.Function.ps1" -Recurse

# Import all functions.
Foreach ($function in $functions)
{
    $path = $function.Name

    . "$PSScriptRoot\function\$path"
}