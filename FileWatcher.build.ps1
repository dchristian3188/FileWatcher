$script:ModuleName = Split-Path -Path $PSScriptRoot -Leaf
$script:OutPutFolder = "Output"
$script:ImportFolders = @('Public','Internal','Classes')
$script:PsmPath = Join-Path $PSScriptRoot -ChildPath "Output\$($script:ModuleName)"


task "Clean" {
    If(-not(Test-Path $script:OutPutFolder))
    {
        New-Item -ItemType Directory -Path $script:OutPutFolder > $null
    }

    Remove-Item -Path "$($script:OutPutFolder)\*" -Force -Recurse
}

task Compile {
    if(Test-Path -Path $script:PsmPath)
    {
        Remove-Item -Path $script:PsmPath -Recurse -Force
    }

    foreach($folder in $script:ImportFolders)
    {
        $currentFolder = Join-Path -Path $script:OutPutFolder -ChildPath $folder
        if(Test-Path -Path $currentFolder)
        {
            Get-ChildItem -File | % {
                Get-Content -Path $PSItem.FullName >> $script:PsmPath 
            }
            
        }
    }
    

}