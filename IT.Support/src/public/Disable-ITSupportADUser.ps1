function Disable-ITSupportADUser {
    <#
    .DESCRIPTION
        Used when a user is termed
    .PARAMETER Identity
        Username of the user being termed
    .PARAMETER TicketNumber
        Ticket number for the term
    .PARAMETER ShareMailboxWithManager
        Share the users mailbox with their manager
    .PARAMETER ShareOneDriveWithManager
        Share the users OneDrive with their manager
    .PARAMETER ShareMailboxWithUser
        Add additional users to the termed user's mailbox
    .PARAMETER ShareOneDriveWithUser
        Add additional users to the termed user's OneDrive
    .PARAMETER SetAutomaticReply
        Configures the default automatic reply message
    .EXAMPLE
        Disable-ITSupportUser -Identity jdoe -TicketNumber 12345
    .EXAMPLE
        Disable-ITSupportUser -Identity jdoe -TicketNumber 12345 -SetAutomaticReply
    .EXAMPLE
        Disable-ITSupportUser -Identity jdoe -TicketNumber 12345 -ShareMailboxWithManager -ShareOneDriveWithManager -SetAutomaticReply
    .EXAMPLE
        Disable-ITSupportUser -Identity jdoe -TicketNumber 12345 -ShareMailboxWithManager -ShareOneDriveWithUser bdoe,fdoe -SetAutomaticReply
    .EXAMPLE
        Disable-ITSupportUser -Identity jdoe -TicketNumber 12345 -ShareMailboxWithManager -ShareMailboxWithUser bdoe,fdoe,rdoe -ShareOneDriveWithManager -ShareOneDriveWithUser bdoe,fdoe -SetAutomaticReply
    .NOTES
        Set account expiration date
        Disable user account
        Move user account to disabled OU
        Update Mailbox
            Convert users mailbox to shared mailbox
                Optional:
                    Give direct manager access to shared mailbox
                    Give specified user(s) access to shared mailbox
            Set automatic reply on users email (optional)
                Internal and External replies can be different
                Supports basic HTML formatting
            Disable server side Outlook rules
        Update OneDrive (optional)
            Optional:
                Give direct manager access to OneDrive
                Give specified user(s) access to OneDrive
        Remove all groups (keep domain users)
            Removes M365 licensing
            Teams phone number is automatically reclaimed
        ServiceDesk Ticket
            Add ticket number to notes section and account description
            Update ServiceDesk ticket with actions performed
            Email direct manager with actions performed
            Email specified user(s) with actions performed (optional)
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Identity,
        [Parameter(Mandatory)]
        [string]$TicketNumber,
        [switch]$ShareMailboxWithManager,
        [switch]$ShareOneDriveWithManager,
        [string[]]$ShareMailboxWithUser,
        [string[]]$ShareOneDriveWithUser,
        [switch]$SetAutomaticReply
    )

    try {
        function getUser {
            # Gets the user's info
            param (
                $UserToDisable
            )

            $userProperties = @{
                Identity   = $userToDisable
                Properties = 'Info', 'Manager'
            }
            $user = Get-ADUser @userProperties -ErrorAction Stop
            "Beginning offboarding of {0}" -f $user.Name | Trace-Output -Level Information
            $prompt = Get-UserInput
            if (!$prompt) {
                throw "Offboarding of {0} has been cancelled" -f $user.Name
            }
            return $user
        }

        function getManager {
            # Gets the manager's info
            param (
                $UsersManager
            )

            $managerName = $UsersManager.Manager.Split(',')[0].Replace('CN=', '')
            $manager = Get-ADUser -Filter "Name -eq '$managerName'" -ErrorAction Stop

            return $manager
        }

        function disableAccount {
            # Disables the users account and adds termination information to their account
            param (
                $UserToDisable,
                $TicketNumber,
                $TermDate
            )

            $currentNotes = $UserToDisable.Info
            $updatedNotes = $currentNotes + "TermTicket:`t$TicketNumber`r`nTermDate:`t$termDate`r`nTermedBy:`t$($env:USERNAME)`n"
            $currentDescription = $UserToDisable.Description
            $updatedDescription = $currentDescription + "TermTicket: {0} TermDate: {1}" -f $TicketNumber, $TermDate
            Set-ADUser -Identity $UserToDisable -Replace @{Info = $updatedNotes; Description = $updatedDescription } -Enabled $false -ErrorAction Stop
            "{0}'s Active Directory account has been disabled" -f $UserToDisable.Name | Trace-Output -Level Information
        }

        function moveDisabledAccount {
            # Move's the disabled account to the specified OU
            param (
                $UserToDisable,
                [PSCredential]$Credential,
                $Destination
            )
            
            Move-ADObject -Identity $UserToDisable -TargetPath $Destination -Credential $Credential -ErrorAction Stop
            "{0}'s Active Directory account has moved to the {1} OU" -f $UserToDisable.Name, $Destination | Trace-Output -Level Information
        }

        function disableOutlookRules {
            # Disables the server side Outlook rules
            param (
                $UserToDisable
            )

            Get-InboxRule -Mailbox $UserToDisable.UserPrincipalName | Remove-InboxRule -AlwaysDeleteOutlookRulesBlob -Confirm:$false -Verbose -ErrorAction Stop
            "{0}'s Outlook rules have been removed" -f $UserToDisable.Name | Trace-Output -Level Information
        }

        function removeADGroups {
            # Remove the user from all groups. Excludes the Domain Users group
            param (
                $UserToDisable
            )

            $groups = Get-ADPrincipalGroupMembership -Identity $UserToDisable | Where-Object { $PSItem.Name -ne 'Domain Users' } -ErrorAction Stop
            Remove-ADPrincipalGroupMembership -Identity $UserToDisable -MemberOf $groups -Confirm:$false -ErrorAction Stop
            "{0}'s has been removed from all Active Directory groups, except for the Domain Users group" -f $UserToDisable.Name | Trace-Output -Level Information
        }

        function setAutomaticReply {
            # Configures the automatic reply to be set on the users mailbox
            param (
                $UserToDisable,
                $Manager
            )

            $internalMessage = "
            Hello,<br>
            <br>
            As of {0}, {1} is no longer an employee of ITInc.<br>
            Please direct your future emails to {2} <{3}>.
            " -f $termDate, $userToDisable.Name, $Manager.Name, $Manager.UserPrincipalName
            $externalMessage = "
            Hello,<br>
            <br>
            As of {0}, {1} is no longer an employee of ITInc.<br>
            Please direct your future emails to {2} <{3}>.
            " -f $termDate, $userToDisable.Name, $Manager.Name, $Manager.UserPrincipalName

            $autoReplyConfig = @{
                Identity                         = $userToDisable.UserPrincipalName
                AutoDeclineFutureRequestsWhenOOF = $true
                DeclineMeetingMessage            = $true
                AutoReplyState                   = 'Scheduled'
                StartTime                        = (Get-Date)
                EndTime                          = ((Get-Date).AddMonths(3))
                InternalMessage                  = $internalMessage
                ExternalMessage                  = $externalMessage
                ExternalAudience                 = 'All'
            }

            Set-MailboxAutoReplyConfiguration @autoReplyConfig -ErrorAction Continue
            "Automatic reply has been configured on {0}'s account until {1}" -f $UserToDisable.Name, $autoReplyConfig.EndTime | Trace-Output -Level Information
        }

        function createOutlookEvent {
            # Adds calendar meeting in Outlook to remove access.
            param (
                $UserToDisable,
                $OffboardingConfig
            )
            $config = ($OffboardingConfig | Out-String)
            $Body = "{0} was offboarded 3 months ago.`nPlease check with the following if the access can be removed or disabled

            $config" -f $UserToDisable.Name
            $termDate = Get-Date

            $createApp = New-Object -ComObject 'Outlook.Application'
            $createEvent = $createApp.CreateItem('olAppointmentItem')
            $createEvent.MeetingStatus = [Microsoft.Office.Interop.Outlook.OlMeetingStatus]::olMeeting
            $createEvent.Subject = ("Update settings for {0}" -f $UserToDisable.Name)
            $createEvent.Body = $Body
            $createEvent.ReminderSet = $true
            $createEvent.Importance = 2
            $createEvent.Start = ($termDate.AddMonths(3).AddMinutes( - ($termDate.Minute % 60)).AddSeconds( - ($termDate.Second)))
            $createEvent.Duration = 30
            $createEvent.ReminderMinutesBeforeStart = 15
            $createEvent.BusyStatus = 0
            $createEvent.Send()
            $createEvent.Save()
            Remove-Variable CreateApp
        }

        
        $termDate = (get-date -Format "dddd, MMMM dd, yyyy")
        $user = getUser -UserToDisable $Identity
        $usersManager = getManager -UsersManager $user
        
        if (Test-ExchangeConnection -ne $true) {
            Connect-Exchange
        }
        
        $offboardingConfig = [PSCustomObject]@{
            'Mailbox shared with: Manager'  = $false
            'Mailbox shared with: User(s)'  = $false
            'OneDrive shared with: Manager' = $false
            'OneDrive shared with: User(s)' = $false
            'Automatic reply configured'    = $false
        }

        # Connects to Exchange and Sharepoint, when needed
        switch -Wildcard ($PSBoundParameters.Keys) {
            'ShareOneDrive*' {
                Connect-SharePoint
            }
        }

        # Only runs the functions if their parameter has been specified when the tool was ran
        switch ($PSBoundParameters.Keys) {
            'ShareMailboxWithManager' {
                Add-ITSupportMailboxMember -Identity $usersManager.UserPrincipalName -Mailbox $user.UserPrincipalName
                #shareMailboxWithManager -UserToDisable $user -Manager $usersManager
                $offboardingConfig.'Mailbox shared with: Manager' = $usersManager.Name
            }
            'ShareOneDriveWithManager' {
                Add-ITSupportOneDriveMember -Identity $usersManager.UserPrincipalName -OneDriveOwner $user.UserPrincipalName
                shareOneDriveWithManager -UserToDisable $user -Manager $usersManager
                $offboardingConfig.'OneDrive shared with: Manager' = $usersManager.Name
            }
            'ShareMailboxWithUser' {
                Add-ITSupportMailboxMember -Identity $ShareMailboxWithUser -Mailbox $user.UserPrincipalName
                #ShareMailboxWithUser -UserToDisable $user -MailboxPermissions $ShareMailboxWithUser
                $offboardingConfig.'Mailbox shared with: User(s)' = ($ShareMailboxWithUser -join ', ')
            }
            'ShareOneDriveWithUser' {
                Add-ITSupportOneDriveMember -Identity $ShareOneDriveWithUser -OneDriveOwner $user.UserPrincipalName
                #ShareOneDriveWithUser -UserToDisable $user -OneDrivePermissions $ShareOneDriveWithUser
                $offboardingConfig.'OneDrive shared with: User(s)' = ($ShareOneDriveWithUser -join ', ')
            }
            'SetAutomaticReply' {
                setAutomaticReply -UserToDisable $User -Manager $usersManager
                $offboardingConfig.'Automatic reply configured' = $true
            }
        }
        disableOutlookRules -UserToDisable $user
        disableAccount -UserToDisable $user -TicketNumber $TicketNumber -TermDate $termDate
        removeADGroups -UserToDisable $
        Convert-ITSupportMailbox -Identity $user.SamAccountName
        
        if ($PSBoundParameters.Keys -like "Share*With*") {
            $destination = $ITUtilities_Private.Config.SyncedDisabledUsersOU
        }
        else {
            $destination = $ITUtilities_Private.Config.DisabledUsersOU
        }

        moveDisabledAccount -UserToDisable $user -Credential (Get-UserCredential) -Destination $Destination
        
        $body = "
        Hello,<br>
        <br>
        {0}'s has been offboarded.
        " -f $user.Name
        Update-Ticket -HtmlBody $body -TicketNumber $TicketNumber
        if ($PSBoundParameters.Keys -like "*share*") {
            createOutlookEvent -UserToDisable $user -OffboardingConfig $offboardingConfig
        }
    }
    catch {
        $PSItem | Format-Exception
    }
}