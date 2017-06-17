[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $OutputPath,

    [Parameter()]
    [String]
    $CompiledModule,

    [Parameter()]
    [switch]
    $Quiet
)

<#
        Super Dirty...
        Not sure how else to load the classes....
#>
Write-Verbose -Message "Invoke module contents of [$CompiledModule]"

$scriptBody = Get-Content -Path $CompiledModule |
    Out-String
Invoke-Expression -Command $scriptBody

function Get-Properties
{
    param($Class)

    New-Object -TypeName $class |
        Get-Member -MemberType Properties |
        Sort-Object -Property Name |
        Select-Object -ExpandProperty Name

}

$graph = graph FileWatcher {
    node @{shape = 'record'}
    $basefile = 'BaseFileWatcher'
    $baseProperties = Get-Properties -Class $basefile
    node $basefile @{shape = 'record'; label = " {BaseFileWatcher |{$($baseProperties -join ' | ')}}"}

    $resources = Get-ChildItem -Path .\DSCResources\*
    foreach ($resource in $resources)
    {
        $resourceProperties = Get-Properties -Class $resource.BaseName
        $resourceProperties = $resourceProperties |
            Where-Object {$baseProperties -notcontains $PSItem}
        $currentNode = $resource.BaseName
        node $currentNode @{shape = 'record'; label = "{$currentNode|{$($resourceProperties -join '|')}}"}
        $allMethods = (Write-Output -InputObject $resourceProperties, $baseProperties |
                Sort-Object) -join '|'
        node "$currentNode Class" @{shape = 'record'; label = "{$currentNode Class|{$allMethods}}"}
        edge $currentNode -To "$currentNode Class"
        edge $basefile -To "$currentNode Class"
    }

}

$exportParams = @{
    Source    = $graph
    ShowGraph = -not($Quiet)
}
if ($OutputPath)
{
    $exportParams['Destination'] = $OutputPath
}
Export-PSGraph @exportParams