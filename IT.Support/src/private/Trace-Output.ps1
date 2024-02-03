function Trace-Output {
    # Writes output to trace file, can also write formatted messages to the host
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]
        $Message,
        [TraceLevel]
        $Level,
        [string]
        $LoggingMode
    )
    if (!$PSBoundParameters.ContainsKey('Level')) {
        $Level = $Script:ITUtilities_Private.LoggingDefaults.Level
    }
    if (!$PSBoundParameters.ContainsKey('LoggingMode')) {
        $LoggingMode = $Script:ITUtilities_Private.LoggingDefaults.LoggingMode
    }
    
    $traceEvent = [PSCustomObject]@{
        Computer     = $env:COMPUTERNAME.ToUpper().ToString()
        FunctionName = (Get-PSCallStack)[1].Command.ToString()
        Level        = $Level.ToString()
        Message      = $Message.ToString()
        Timestamp    = [DateTime]::Now.ToString('MM/dd/yyyy HH:mm:ss tt')
    }
    
    if ($LoggingMode -eq 'Database') {
        $traceEvent | Write-SqlRow
    }
    else {
        $traceFile = Get-TraceOutputFile
        $traceEvent | Export-Csv -Path $traceFile -NoTypeInformation -Append
    }

    switch ($Level) {
        'Verbose' {
            break
        }
        'Information' {
            "[{0}][{1}]" -f $traceEvent.Computer, $traceEvent.Timestamp | Write-Host -ForegroundColor Cyan -NoNewline
            " {0}" -f $traceEvent.Message | Write-Host -ForegroundColor Green
            break
        }
        'Warning' {
            "[{0}]" -f $traceEvent.Computer | Write-Host -ForegroundColor Cyan -NoNewline
            " WARNING: {0}" -f $traceEvent.Message | Write-Host -ForegroundColor Yellow
            break
        }
        'Exception' {
            "[{0}]" -f $traceEvent.Computer | Write-Host -ForegroundColor Cyan -NoNewline
            " {0}" -f $traceEvent.Message | Write-Host -ForegroundColor Red
            break
        }
        Default {
            "[{0}]" -f $traceEvent.Computer | Write-Host -ForegroundColor Cyan -NoNewline
            " {0}" -f $traceEvent.Message | Write-Host -ForegroundColor Cyan
            break
        }
    }
}