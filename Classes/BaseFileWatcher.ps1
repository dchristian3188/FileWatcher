class BaseFileWatcher
{
    [DscProperty(Mandatory)]
    [String[]]
    $Path

    [DscProperty()]
    [String]
    $Filter

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]]
    $ProcessStartTime

    [DscProperty(NotConfigurable)]
    [Nullable[datetime]]
    $LastWriteTime

    [BaseFileWatcher]Get()
    {
        $this.ProcessStartTime = $this.GetProcessStartTime()
        $this.LastWriteTime = $this.GetLastWriteTime()
        Return $this
    }

    [Bool]Test()
    {
        if (-not($this.ProcessStartTime))
        {
            $this.ProcessStartTime = $this.GetProcessStartTime()
        }

        if (-not($this.LastWriteTime))
        {
            $this.LastWriteTime = $this.GetLastWriteTime()
        }

        if ($this.ProcessStartTime -ge $this.LastWriteTime)
        {
            Write-Verbose -Message "Process has a later start time. No action will be taken"
            Return $true
        }
        Else
        {
            Write-Verbose -Message "One or more files has a later start time. The process will be restarted."
            Return $false
        }
    }

    [DateTime]GetLastWriteTime()
    {
        $getSplat = @{
            Path = $this.Path
            Recurse = $true
        }

        Write-Verbose -Message "Checking Path: $($this.Path -join ", ")"
        if ($this.Filter)
        {
            Write-Verbose -Message "Using Filter: $($this.Filter)"
            $getSplat["Filter"] = $this.Filter
        }

        $lastWrite = Get-ChildItem @getSplat |
            Sort-Object -Property LastWriteTime |
            Select-Object -ExpandProperty LastWriteTime -First 1

        if (-not($lastWrite))
        {
            Write-Verbose -Message "No lastwrite time found. Setting to min date"
            $lastWrite = [datetime]::MinValue
        }

        Write-Verbose -Message "Last write time: $lastWrite"
        return $lastWrite
    }
}
