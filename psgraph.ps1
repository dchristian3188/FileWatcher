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

graph b {
    node @{shape = 'record'}
    $basefile = 'BaseFileWatcher'
    $baseMethods = Get-Methods -File .\Classes\BaseFileWatcher.ps1
    node $basefile @{shape = 'record'; label = " {BaseFileWatcher |{$($baseMethods -join ' | ')}}"}

    $resources = Get-ChildItem -Path .\DSCResources\*
    foreach($resource in $resources)
    {
        $resourceMethods = Get-methods -file $resource.FullName
        $currentNode = $resource.BaseName
        node $currentNode @{shape = 'record'; label = "{$currentNode|{$($resourceMethods -join '|')}}"}
        $allMethods = (Write-Output -InputObject $resourceMethods, $baseMethods) -join '|'
        node "$currentNode Class" @{shape = 'record'; label = "{$currentNode Class|{$allMethods}}"}
        edge $currentNode -To "$currentNode Class"
        edge $basefile -To "$currentNode Class"
    }

} | Export-PSGraph -ShowGraph