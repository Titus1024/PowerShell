function Add-ITSupportMailboxMember {
    <#
    .DESCRIPTION
    Shares the users mailbox with the requested user(s)
    .PARAMETER Identity
    The user to be added to the selected mailbox
    .PARAMETER Mailbox
    The mailbox that will have the selected user added to
    .PARAMETER AccessRights
    Type of access the user will have on the mailbox
    By default, the access to be granted is FullAccess
    .PARAMETER TicketNumber
    The ticket to update regarding the mailbox change
    .PARAMETER Message
    An optional HTML formatted message can be provided that will be sent to the selected user and the ticket
    The default message is used if none is provided
    .EXAMPLE
    Example description
    .NOTES
    Any additional information 
#>
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]
        $Identity,
        [Parameter(Mandatory)]
        [string]
        $Mailbox,
        [ValidateSet("FullAccess", "ReadPermission")]
        $AccessRights,
        [Parameter(Mandatory)]
        [string]
        $TicketNumber,
        [string]
        $Message
    )

    try {
        if (!(Test-ExchangeConnection)) {
            Connect-Exchange
        }

        $usersToAdd = @()
        
        foreach ($user in $Identity) {
            $userToAdd = Get-ADUser -Identity $user
            $usersToAdd += $userToAdd
            $null = Add-MailboxPermission -Identity $Mailbox -User $userToAdd.UserPrincipalName -AccessRights $AccessRights -ErrorAction Stop -WarningAction Ignore
            "{0} has been granted {1} on the {2} mailbox" -f ($userToAdd.Name -join ', '), $AccessRights, $Mailbox | Trace-Output -Level Information
        }

    
        $subject = "Request : ##RE-$TicketNumber##"

        if ($PSBoundParameters.Keys -notcontains 'Message') {
            $body = "
        Hello,<br>
        <br>
        You have been given access to the shared mailbox <strong>{0}</strong> for 3 months.<br>
        If you have the Outlook desktop application the mailbox should show up automatically within 30 minutes, if not, please restart Outlook.<br>
        If you use Outlook on the web, please respond to this email and a technician will assist you with adding the shared mailbox.<br>
        " -f $Mailbox
        }
        $cc = ($usersToAdd | Select-Object -ExpandProperty UserPrincipalName) -join ', '
        Send-Email -Subject $subject -Body $body -Cc $cc 
    }
    catch {
        $PSItem | Format-Exception
    }
}
