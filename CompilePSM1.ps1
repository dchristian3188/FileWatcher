Split-Path -Leaf $PSScriptRoot
$classes = Get-ChildItem -Path $PSScriptRoot\Classes
$classesToExport = @{}

$classContent = foreach($class in $classes)
{
    If($class.BaseName -ne 'BaseFileWatcher')
    {
        $classesToExport[$class.BaseName] = '1'
    }    
    Get-Content -Path $class.FullName
}


$classesToExport.Keys.GetEnumerator()
Set-Content -Path $PSScriptRoot\Test.psm1 -Value $classContent 