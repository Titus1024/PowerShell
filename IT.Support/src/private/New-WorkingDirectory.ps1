function New-WorkingDirectory {
    # Creates a new working directory
    # Working directory used for trace file, logs, and other files related to the session
    try {
        if ((Test-Path -Path C:\temp) -eq $false) {
            New-Item -Path C:\temp -ItemType Directory -Confirm:$false -ErrorAction Stop | Out-Null
        }
        $date = (Get-Date -Format yyyyMMddhhmmss)
        $moduleName = ($PSScriptRoot -split '\\')[-3]
        $dirName = "$moduleName\$date"
        $newDir = Join-Path -Path C:\temp -ChildPath $dirName
        $workingDir = New-Item -Path $newDir -ItemType Directory -Confirm:$false -ErrorAction Stop
        "New working directory created. Your current working directory is {0}" -f $workingDir | Write-Host -ForegroundColor Cyan
        Set-WorkingDirectory -Directory $workingDir.FullName

        New-TraceOutputFile
    }
    catch {
        Write-Warning $PSItem.Exception.Message
    }
}   