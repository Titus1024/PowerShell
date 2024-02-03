# Scriptblocks hashtable
$scriptBlocks = @{
    ADFilters         = {
        (ConvertFrom-Json -Path "$PSScriptRoot\config\config.json" | Select-Object -ExpandProperty ADFilters | Get-Member | Where-Object { $PSItem.NoteProperty -eq 'NoteProperty' } | Where-Object { $PSItem.Name -like "*$WordToComplete*" }) | ForEach-Object {
            "'$PSItem'"
        }
    }
    ADGroups          = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
        (Get-ADGroup -SearchBase $ITUtilities_Private.Config.UserOU -Filter "Name -like '*$WordToComplete*'").Name | ForEach-Object {
            "'$PSItem'"
        }
    }
    ComputerName     = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
        (Get-ADComputer -SearchBase $ITUtilities_Private.Config.ComputerOU -Filter "Name -like '*$WordToComplete*'").Name | ForEach-Object {
            "'$PSItem'"
        }
    }
    GraphScopes       = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
        (ConvertFrom-Json -Path "$PSScriptRoot\config\config.json" | Select-Object -ExpandProperty GraphScopes | Get-Member | Where-Object { $PSItem.NoteProperty -eq 'NoteProperty' } | Where-Object { $PSItem.Name -like "*$WordToComplete*" }) | ForEach-Object {
            "'$PSItem'"
        }
    }
    SamAccountName    = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
        (Get-ADUser -SearchBase $ITUtilities_Private.Config.UserOU -Filter "samAccountName -like '*$WordToComplete*'").SamAccountName | ForEach-Object {
            "'$PSItem'"
        }
    }
    UserPrincipalName = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
        (Get-ADUser -SearchBase $ITUtilities_Private.Config.UserOU -Filter "UserPrincipalName -like '*$WordToComplete*'").UserPrincipalName | ForEach-Object {
            "'$PSItem'"
        }
    }
}

# Array of commands, requires common parameters
$adGroupCommands = @(
    'Get-ItIncSupportADGroupMember'
    'Add-ItIncSupportADGroupMember'
)

$computerNameCommands = @(
    'Get-ItIncSupportBitLockerKey'
)

$samAccountNameCommands = @(
    'Add-ItIncSupportADGroupMember'    
    'Add-ItIncSupportMailboxMember'
    'Block-ItIncSupportADUser'
    'Disable-ItIncSupportADUser'
    'Get-ItIncSupportADUser'
    'Get-ItIncSupportBitLockerKey'
    'Reset-ItIncSupportPassword'
    'Unlock-ItIncSupportAccount'
)
    
$userPrincipalNameCommands = @(
    'Add-ItIncSupportMailboxMember'
    'Add-ItIncSupportOneDriveUser'
    'Convert-ItIncSupportMailbox'
    'Disable-ItIncSupportADUser'
)

# Create the argument completers
Register-ArgumentCompleter -CommandName $adGroupCommands -ParameterName 'GroupName' -ScriptBlock $scriptBlocks.ADGroups
Register-ArgumentCompleter -CommandName $computerNameCommands -ParameterName 'ComputerName' -ScriptBlock $scriptBlocks.ComputerName
Register-ArgumentCompleter -CommandName $samAccountNameCommands -ParameterName 'Identity' -ScriptBlock $scriptBlocks.SamAccountName
Register-ArgumentCompleter -CommandName $userPrincipalNameCommands -ParameterName 'Mailbox' -ScriptBlock $scriptBlocks.UserPrincipalName
Register-ArgumentCompleter -CommandName $userPrincipalNameCommands -ParameterName 'ShareOneDriveWithUser' -ScriptBlock $scriptBlocks.UserPrincipalName
Register-ArgumentCompleter -CommandName $userPrincipalNameCommands -ParameterName 'ShareMailboxWithUser' -ScriptBlock $scriptBlocks.UserPrincipalName