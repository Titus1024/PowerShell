param(
    [switch]$SkipStartUp
)

# Argument completers, configurations, and enums imported here
. "$PSScriptRoot\src\IT.Support.Config.ps1"
. "$PSScriptRoot\src\IT.Support.Helper.ps1"

foreach ($script in (Get-ChildItem "$PSScriptRoot\src\private\")) {
    . $script.FullName
}
foreach ($script in (Get-ChildItem "$PSScriptRoot\src\public\")) {
    . $script.FullName
}

New-WorkingDirectory

if (!$SkipStartUp) {
    Start-Module
}