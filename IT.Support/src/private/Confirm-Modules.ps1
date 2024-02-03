function Confirm-Modules {
    # Checks for required modules
    [System.Collections.Generic.List[object]]$modules = $script:ITUtilities_Private.Config.RequiredModules
    $checkModules = Get-Module -Name $modules -ListAvailable
    if ($checkModules.Count -eq $modules.Count) {
        'Required modules are present' | Trace-Output -Level Information
    }
    else {
        'Required modules are not present' | Trace-Output -Level Warning
        'Attempting to install...' | Trace-Output -Level Information
        if ($checkModules.Name -notcontains 'ActiveDirectory') {
            if (!(Test-Administrator)) {
                throw [System.UnauthorizedAccessException]::new('Administrator access is required to install the ActiveDirectory module')
            }
            Add-WindowsCapability -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0' -Online -ErrorAction Stop
            'ActiveDirectory module has been installed, restart your computer to access it' | Trace-Output -Level Warning
            $modules.Remove($modules[$modules.FindIndex({ $args[0] -eq 'ActiveDirectory' })])
        }
        $modules.AddRange($checkModules.Name)
        $modulesToInstall = $modules | Group-Object | Where-Object { $PSItem.Group.Count -eq 1 }
        Install-Module $modulesToInstall.Group -Scope CurrentUser -Verbose -ErrorAction Stop -Repository PSGallery
        'Required modules have been installed' | Trace-Output -Level Information
    }
}