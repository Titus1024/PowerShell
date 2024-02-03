function New-TraceOutputFile {
    # Creates a new trace output file
    $workingDir = Get-WorkingDirectory
    if ((Test-Path -Path $workingDir) -eq $false) {
        New-Item -Path $workingDir -ItemType Directory
    }

    $traceFile = "traceFile_{0}.csv" -f (Get-Date -Format "yyyy_MM_dd")
    $tracePath = Join-Path -Path $workingDir -ChildPath $traceFile
    New-Item -Path $tracePath -ItemType File

    Set-TraceOutputFile -TraceOutputFile $tracePath
}