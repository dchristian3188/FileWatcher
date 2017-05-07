[DscResource()]
class ServiceFileWatcher : BaseFileWatcher
{

    [DscProperty(Key)]
    [string]
    $ServiceName
    
    [Void]Set()
    {
        Restart-Service -Name $this.ServiceName -Force
    }
    
    [DateTime]GetProcessStartTime()
    {
        $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$($this.ServiceName)'" -ErrorAction Stop
        If (-not($service))
        {
            Throw "Could not find a service with name: $($this.ServiceName)"
        }

        Write-Verbose -Message "Checking for process id: $($service.ProcessId)"
        $processInfo = (Get-CimInstance win32_process -Filter "processid='$($service.ProcessId)'")
        
        If ($processInfo.ProcessId -eq 0)
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