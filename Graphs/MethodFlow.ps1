[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $OutputPath,

    [Parameter()]
    [switch]
    $Quiet
)
Function Get-Methods
{
    Param($File)
    $contents = Get-Content -Path $file -ErrorAction Stop
    $contents.ForEach{
        if ($PSItem -match '(\])(?<methodName>\w*)(\(\))')
        {
            $Matches.methodName
        }
    }
}

$graph = graph FileWatcher {
    node @{shape = 'record'}
    $basefile = 'BaseFileWatcher'
    $baseMethods = Get-Methods -File .\Classes\BaseFileWatcher.ps1 |
        Sort-Object
    node $basefile @{shape = 'record'; label = " {BaseFileWatcher |{$($baseMethods -join ' | ')}}"}

    $resources = Get-ChildItem -Path .\DSCResources\*
    foreach ($resource in $resources)
    {
        $resourceMethods = Get-methods -file $resource.FullName |
            Sort-Object
        $currentNode = $resource.BaseName
        node $currentNode @{shape = 'record'; label = "{$currentNode|{$($resourceMethods -join '|')}}"}
        $allMethods = (Write-Output -InputObject $resourceMethods, $baseMethods |
                Sort-Object) -join '|'
        node "$currentNode Class" @{shape = 'record'; label = "{$currentNode Class|{$allMethods}}"}
        edge $currentNode -To "$currentNode Class"
        edge $basefile -To "$currentNode Class"
    }

}

$exportParams = @{
    Source = $graph
    ShowGraph = -not($Quiet)
}
if($OutputPath)
{
    $exportParams['Destination'] = $OutputPath
}
Export-PSGraph @exportParams