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
        Import-Module (Join-Path -Path $ModuleRoot -ChildPath "$($ModuleName).psm1"
    }

    AfterAll {
        Remove-Module -Name $ModuleName
    }

    Context "Service File Watcher Tests" {
        It "Creates a new object" {
            {$serviceFW = [ServiceFileWatcher]::new()} | Should not throw
        }
    }

}
