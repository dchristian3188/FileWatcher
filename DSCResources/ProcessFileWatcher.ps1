[DscResource()]
class ProcessFileWatcher : BaseFileWatcher
{

    [DscProperty(Key)]
    [string]
    $ProcessName

    [DscProperty(Mandatory=$true)]
    [string]
    $ProcessPath

    [DscProperty()]
    [string]
    $ProcessStartArgs
    
    [Void]Set()
    {
        $runningProcs = Get-Process -Name $this.ProcessName -ErrorAction SilentlyContinue

        If($runningProcs)
        {
            Write-Verbose -Message "Stopping running Processes $($runningProcs.ID -join ', ')"
            $runningProcs | 
                Stop-Process -ErrorAction Stop -Force
        }

        Write-Verbose -Message "Starting Process [$($this.ProcessName)] at path [$($this.ProcessPath)] with args [$($this.ProcessStartArgs)]"
        Start-Process -FilePath $this.ProcessPath -ArgumentList $this.ProcessStartArgs -PassThru
    }
    
    [DateTime]GetProcessStartTime()
    {
        Write-Verbose -Message "Checking for process Name: $($this.ProcessName)"
        $processInfo = (Get-CimInstance win32_process -Filter "name='$($this.ProcessName)'")
        
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
