[CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $ModuleRoot = (Resolve-Path "$PSScriptRoot\.."),

        [Parameter()]
        [string]
        $ModuleName = (Split-Path (Resolve-Path "$PSScriptRoot\..") -Leaf)
    )

Describe "General project validation: $ModuleName" {

    $scripts = Get-ChildItem $ModuleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | Foreach-Object {@{file = $_}}
    It "Script <file> should be valid powershell" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    It "Module [$ModuleName] can import cleanly from [$ModuleRoot]" {
        {Import-Module (Join-Path $ModuleRoot "$ModuleName.psm1") -force } | Should Not Throw
    }
}