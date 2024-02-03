function Test-Administrator {
    # Checks if the current shell has administrator access and returns a boolean value
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    $result = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    return $result
}