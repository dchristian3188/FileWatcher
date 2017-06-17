[DscResource()]
class WebSiteFileWatcher : BaseFileWatcher
{

    [DscProperty(Key)]
    [string]
    $WebsiteName

    [Void]Set()
    {
        $webInfo = Get-Website -Name $this.WebsiteName
        Write-Verbose -Message "Restarting Application pool [$($webInfo.applicationPool)]"
        Restart-WebAppPool -Name $webInfo.applicationPool
    }

    [DateTime]GetProcessStartTime()
    {

        Write-Verbose -Message "Checking for Application pool running [$($this.WebsiteName)]"
        $websiteInfo = Get-Website -Name $this.WebsiteName

        if(-not($websiteInfo))
        {
            throw "Unable to find website $($this.WebsiteName)"
        }

        Write-Verbose -Message "Checking for process running applicaiton pool: $($websiteInfo.applicationPool)"

        $AppPoolName = @{
            Name       = 'AppPoolName'
            Expression = {(Invoke-CimMethod -InputObject $PSItem -MethodName 'GetOwner').User}
        }
        $processInfo = (Get-CimInstance win32_process -Filter "name='w3wp.exe'") |
            Select-Object *, $AppPoolName |
            Where-Object -FilterScript {$PSItem.AppPoolName -eq $($websiteInfo.applicationPool)}

        if (($processInfo.ProcessId -eq 0) -or $processInfo -eq $null)
        {
            Write-Verbose -Message "Could not find a running process, setting start time to min date value"
            $processStart = [datetime]::MinValue
        }
        Else
        {
            $processStart = $processInfo.CreationDate
            Write-Verbose -Message "Process started at: $($processStart)"
        }
        Return $processStart
    }


}
