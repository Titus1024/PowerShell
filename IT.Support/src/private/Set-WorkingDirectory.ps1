function Set-WorkingDirectory {
    # Caches the trace output folder path
    param (
        [Parameter(Mandatory)]$Directory
    )
    $script:ITUtilities_Private.Cache.WorkingDirectory = $Directory
    Set-Location $script:ITUtilities_Private.Cache.WorkingDirectory
}