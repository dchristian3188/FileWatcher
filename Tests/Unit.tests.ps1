[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $ModuleRoot = (Resolve-Path "$PSScriptRoot\.."),

    [Parameter()]
    [string]
    $ModuleName = (Split-Path (Resolve-Path "$PSScriptRoot\..") -Leaf)
)

Describe "$($ModuleName) Unit Tests" {
    BeforeAll {
        <#
             Super Dirty...
             Not sure how else to load the classes....
        #>
        $modulePath = Join-Path -Path $ModuleRoot -ChildPath "$($ModuleName).psm1"
        Write-Verbose -Message "Invoke module contents of  [$psmPath]"

        $scriptBody = Get-Content -Path $modulePath |
            Out-String
        Invoke-Expression -Command $scriptBody

        $resourcesFolder = Resolve-Path -Path "$PSScriptRoot\..\DSCResources"
        $resources = Get-ChildItem -Path $resourcesFolder -File |
            Select-Object -ExpandProperty BaseName
    }

    AfterAll {
    }

    foreach ($resource in $resources)
    {
        Context "$resource Tests" {
            It "$resource Creates a new object" {
                {$fw = New-Object -TypeName $resource} | Should not throw
            }

            It ""
        }
    }



}
