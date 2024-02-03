function Get-WorkingDirectory {
    # Returns the cached working directory path
    return $script:ITUtilities_Private.Cache.WorkingDirectory
}