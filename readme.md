# PowerShell Module for IT Support

This module is designed to help IT support staff perform common tasks more efficiently and effectively. It uses an internal JSON config file to store the settings and parameters for various systems and commands, such as ExchangeOnline, Microsoft Teams, and ActiveDirectory. This reduces the duplication of code and centralizes the configuration.

The module also supports tab completion via ArgumentCompleters for all commands that accept parameters. This makes it easier to enter the correct values and avoid typos.

The module simplifies the process of connecting to, testing, and leveraging the systems mentioned above. For example, you can use the `Connect-Exchange` function to establish a remote PowerShell session with ExchangeOnline, and then use the `Get-ITSupportMailboxMember` function to retrieve the members of a mailbox.

The module can also be used to send Teams chat messages via the `Send-TeamsChatMessage` function, which uses the Microsoft Graph API to communicate with the Teams service. You can use this function to notify users or colleagues about the status of their tickets, requests, or issues.

## Installation

To install the module, you need to download or clone the repository from GitHub:

```powershell
git clone https://github.com/Titus1024/PowerShell.git
```

Then, you need to copy the folder `PowerShell` to one of the paths in your `$env:PSModulePath` variable. For example, you can copy it to `C:\Users\YourUserName\Documents\WindowsPowerShell\Modules`.

Alternatively, you can use the `Install-Module` cmdlet from the PowerShell Gallery (coming soon).

## Usage

To use the module, you need to import it first:

```powershell
Import-Module PowerShell
```

Then, you can use any of the public or private functions in the module. The public functions are intended to be used by the IT support staff, while the private functions are used internally by the module or for debugging purposes.

The public functions are:

- `Add-ITSupportADGroupMember`: Adds a user to an Active Directory group.
- `Add-ITSupportMailboxMember`: Adds a user to a mailbox or a distribution group in ExchangeOnline.
- `Add-ITSupportOneDriveUser`: Grants a user access to another user's OneDrive folder in SharePoint.
- `Block-ITSupportADUser`: Blocks a user from logging in to the domain.
- `Convert-ITSupportMailbox`: Converts a mailbox from one type to another in ExchangeOnline, such as from a user mailbox to a shared mailbox.
- `Copy-ITSupportADGroupMembership`: Copies the group membership of one user to another in Active Directory.
- `Disable-ITSupportADUser`: Completely off-boards a user account in Active Directory.
- `Get-ITSupportADGroupMember`: Gets the members of an Active Directory group.
- `Get-ITSupportADUser`: Gets the properties of a user account in Active Directory.
- `Get-ITSupportBitLockerKey`: Gets the BitLocker recovery key of a computer from Active Directory.
- `Get-ITSupportLockedAccount`: Gets the locked out accounts in the domain from Active Directory.
- `Reset-ITSupportPassword`: Resets the password of a user account in Active Directory.
- `Start-ITSupportADUserAudit`: Starts an audit of the user accounts in Active Directory and generates a report in CSV format.
- `Unlock-ITSupportAccount`: Unlocks a user account in Active Directory.

For more details and examples on how to use each function, you can use the `Get-Help` cmdlet:

```powershell
Get-Help Add-ITSupportADGroupMember -Full
```

The private functions that support the module's functionality are:

- `Confirm-Modules.ps1`
- `Connect-Exchange.ps1`
- `Connect-MicrosoftGraph.ps1`
- `Connect-SharePoint.ps1`
- `Format-Exception.ps1`
- `Format-Output.ps1`
- `Get-ADFilter.ps1`
- `Get-MicrosoftGraphScopes.ps1`
- `Get-MicrosoftGraphUser.ps1`
- `Get-TraceOutputFile.ps1`
- `Get-UserCredential.ps1`
- `Get-UserInput.ps1`
- `Get-WorkingDirectory.ps1`
- `New-Stopwatch.ps1`
- `New-TeamsChat.ps1`
- `New-TraceOutputFile.ps1`
- `New-WorkingDirectory.ps1`
- `Send-Email.ps1`
- `Send-TeamsChatMessage.ps1`
- `Set-TraceOutputFile.ps1`
- `Set-WorkingDirectory.ps1`
- `Split-TextOnLineWidth.ps1`
- `Start-Module.ps1`
- `Test-Administrator.ps1`
- `Test-DatabaseConnection.ps1`
- `Test-ExchangeConnection.ps1`
- `Test-MicrosoftGraphConnection.ps1`
- `Test-SharePointConnection.ps1`
- `Test-VPNConnection.ps1`
- `Trace-Output.ps1`
- `Update-Ticket.ps1`
- `Write-SqlRow.ps1`

## Feedback and Issues

If you have any feedback, suggestions, or issues with the module, please feel free to open an issue or a pull request on GitHub. I appreciate your input and support.
