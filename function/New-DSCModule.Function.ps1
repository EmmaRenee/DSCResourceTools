<#
.SYNOPSIS
    New-DSCModule function
.DESCRIPTION
    This function creates a bare bones class based DSC Resource Modeled including all files and folders from a template contained in text files.
.EXAMPLE
    PS C:\> New-DSCModule -Name 'TestResource' -ModulePath '.\Projects\SCCM' -Author 'Emma Renee' -vscode -Verbose
    Creates a new DSC Resource Module named TestResource. 
.NOTES
    There are other tools already in existance that accomplish the same thing. I created this module to standardize my module development per my own preferences.

    Release Notes:
    1/11/2019 - First version of function is released.

    To do:
    - pester tests need to be written
    - function documentation needs to be created
    - expand manifest options
    - optional class naming
    - option for creation of multiple classes
#>

[CmdletBinding]
Function New-DSCModule
{
    Param(
        # Module Name
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        # Module Path
        [Parameter(Mandatory=$false)]
        [string]
        $ModulePath = $env:ProgramFiles + "\WindowsPowerShell\Modules",

        # Module Author
        [Parameter(Mandatory=$true)]
        [string]
        $Author,

        # Company Name
        [Parameter(Mandatory=$false)]
        [string]
        $CompanyName = 'n/a',

        # Module Version
        [Parameter(Mandatory=$false)]
        [string]
        $ModuleVersion = '0.0.1',

        # Add vscode settings files
        [Parameter(Mandatory=$false)]
        [switch]
        $vscode
    )

    Write-Verbose "Starting build of new module for $Name"

    $ContentPath = $PSScriptRoot.Replace('function','content')
    $path = "$ModulePath\$Name\$ModuleVersion"

    $folders = New-Object -TypeName System.Collections.ArrayList
    $folders.Add("$path")
    $folders.Add("$path\class")
    $folders.Add("$path\test")
    If ($vscode) { $folders.Add("$path\.vscode") }
    
    Write-Verbose "Creating module folders"

    foreach ($folder in $folders) {
        New-Item -Path $folder -ItemType Directory
    }

    Write-Verbose 'Generating new module manifest'

    New-ModuleManifest -Path "$path\$Name.psd1" `
                       -RootModule "$Name.psm1" `
                       -Guid $(New-Guid) `
                       -Author $Author `
                       -CompanyName $CompanyName `
                       -Copyright "(c) $((Get-Date).Year) $(If ($CompanyName -ne 'n/a') { $CompanyName } Else { $Author }). All rights reserved." `
                       -ModuleVersion $ModuleVersion `
                       -DscResourcesToExport @('ExampleResource') 
    
    Write-Verbose 'Generating PowerShell module file'

    $files = New-Object -TypeName System.Collections.ArrayList
    $files.Add(@{SourceName = 'DSC-Template'; DestName = $Name; Ext = 'psm1'; Path = ''})
    $files.Add(@{SourceName = 'DSC-Template.Tests'; DestName = $Name; Ext = 'ps1'; Path = '\test'})
    $files.Add(@{SourceName = 'ExampleResource.Class'; DestName = 'ExampleResource.Class'; Ext = 'ps1'; Path = '\class'})
    If ($vscode)
    {
        $files.Add(@{SourceName = 'settings'; DestName = 'settings'; Ext = 'json'; Path = '\.vscode'})
        $files.Add(@{SourceName = 'tasks'; DestName = 'tasks'; Ext = 'json'; Path = '\.vscode'})
    }
    
    Foreach ($file in $files)
    {
        Write-Verbose "Writeing file $($file.DestName).$($file.Ext)"

        $content = Get-Content "$ContentPath\$($file.SourceName).txt"
        Add-Content -Path "$path$($file.Path)\$($file.DestName).$($file.Ext)" -Value $content
    }   
}