[DscResource()]
class ProcessFileWatcher : BaseFileWatcher
{

    [DscProperty(Key)]
    [string]
    $ProcessName

    [DscProperty(Mandatory = $true)]
    [string]
    $ProcessPath

    [DscProperty()]
    [string]
    $ProcessStartArgs

    [Void]Set()
    {
        $runningProcs = Get-CimInstance win32_process -Filter "name='$($this.ProcessName)'"

        If ($runningProcs)
        {
            Write-Verbose -Message "Stopping running Processes $($runningProcs.ProcessId -join ', ')"
            Stop-Process -ID $runningProcs.ProcessId -ErrorAction Stop -Force
        }

        Write-Verbose -Message "Starting Process [$($this.ProcessName)] at path [$($this.ProcessPath)] with args [$($this.ProcessStartArgs)]"

        $startProcessArgs = @{
            FilePath = $this.ProcessPath
            PassThru = $true
        }
        if (-not([string]::IsNullOrEmpty($this.ProcessStartArgs)))
        {
            $startProcessArgs['ArgumentList'] = $this.ProcessStartArgs
        }
        Start-Process @startProcessArgs
    }

    [DateTime]GetProcessStartTime()
    {
        Write-Verbose -Message "Checking for process Name: $($this.ProcessName)"
        $processInfo = (Get-CimInstance win32_process -Filter "name='$($this.ProcessName)'")

        If ($processInfo.ProcessId -eq $null)
        {
            Write-Verbose -Message "Could not find a running process, setting start time to min date value"
            $processStart = [datetime]::MinValue
        }
        Else
        {
            $processStart = $processInfo |
                Sort-Object -Property CreationDate -Descending |
                Select-Object -ExpandProperty CreationDate -First 1

            Write-Verbose -Message "Process started at: $($processStart)"
        }
        Return $processStart
    }

}
