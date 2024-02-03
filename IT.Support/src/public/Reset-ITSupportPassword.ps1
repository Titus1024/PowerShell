function Reset-ITSupportPassword {
    <#
    .DESCRIPTION
    Resets an AD user's password, provides the temporary password to them, and updates the service desk ticket
    It can also change the ChangePasswordAtLogon flag, and unlock the AD account
    .PARAMETER Identity
    Username of the user having their password reset
    .PARAMETER RandomPassword
    Uses a randomly generated password instead of the default password
    .PARAMETER ChangePasswordAtLogon
    Used to set the ChangePasswordAtLogon flag, by default this is enabled
    .PARAMETER UnlockAccount
    Unlocks the AD account
    .PARAMETER TicketNumber
    Ticket number used to track the password change
    .EXAMPLE
    Reset-ITSupportPassword -Identity mpolselli
    .EXAMPLE
    Reset-ITSupportPassword -Name mpolselli -UnlockAccount
    .EXAMPLE
    Reset-ITSupportPassword -Identity mpolselli -ChangePasswordAtLogon:$false -UnlockAccount
    .NOTES
    Tab auto complete for user's username
    Reset password using standard temporary password
        Optional:
            Reset multiple passwords at once
            Parameter to not require password reset upon login
            Use standard password or randomly generated password
            Unlock account
    Send email to update ticket
    Send Teams message to user(s) having password reset and provide their new password
    #>
    [Cmdletbinding(DefaultParameterSetName = "SingleUser")]
    param (
        [Parameter(Mandatory, ParameterSetName = "SingleUser")]
        [string]$Identity,
        [Parameter(ParameterSetName = "MultipleUser")]
        [string[]]$MultipleUsers,
        [switch]$UnlockAccount,
        [bool]$ChangePasswordAtLogon,
        [switch]$RandomPassword,
        [Parameter(Mandatory, ParameterSetName = "SingleUser")]
        [string]$TicketNumber
    )

    function getUser {
        param (
            $Username
        )
        "Resetting password for {0}" -f $Username | Trace-Output -Level Information
        $prompt = Get-UserInput
        if (!$prompt) {
            throw 'Password reset cancelled'
        }
        try {
            $user = Get-ADUser -Identity $Username -Properties Department -ErrorAction Stop
            return $user
        }
        catch {
            throw "{0} was not found in AD" -f $user.Name
        }
    }

    function generateRandomPassword {
        param(
            $Username
        )
        $secureString = [System.Web.Security.Membership]::GeneratePassword(16, 5) | ConvertTo-SecureString -AsPlainText -Force
        $encryptedPassword = [PSCredential]::new($Username.SamAccountName, $secureString)
        return $encryptedPassword
    }

    function generateStandardPassword {
        param(
            $Username
        )
        $standardPasswordConfig = [ordered]@{
            FirstName  = $Username.GivenName[0]
            LastName   = $Username.Surname[0]
            DateString = (Get-Date -Format 'yyyyMMdd')
            Department = $Username.Department
            Company    = 'B!1nC'
        }
        $private:standardPassword = ''
        foreach ($char in $standardPasswordConfig.GetEnumerator()) {
            $private:standardPassword += $char.Value
            $private:standardPassword += ' '
        }
        $secureString = $private:standardPassword.TrimStart().TrimEnd() | ConvertTo-SecureString -AsPlainText -Force
        Remove-Variable standardPassword -Scope Private
        $encryptedPassword = [PSCredential]::new($Username.SamAccountName, $secureString)

        return $encryptedPassword
    }

    function unlockAccount {
        param(
            $Username
        )
        Unlock-ADAccount -Identity $Username -ErrorAction Stop
        "Account has been unlocked" | Trace-Output
    }

    function changePasswordAtLogon {
        param(
            $Username,
            [bool]$ChangePasswordAtLogon
        )

        Set-ADUser -Identity $Username -ChangePasswordAtLogon $ChangePasswordAtLogon -ErrorAction Stop
        "Change password at logon has been set to {0}" -f $ChangePasswordAtLogon | Trace-Output
    }

    function setPassword {
        param(
            [pscredential]$NewPassword
        )

        Set-ADAccountPassword -Identity $NewPassword.UserName -NewPassword $NewPassword.Password -ErrorAction Stop
        'Password has been reset' | Trace-Output -Level Information
    }

    function sendPasswordToUser {
        param(
            [PSCredential]$NewPassword
        )
        $memUnicode = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($NewPassword.Password)
        $private:decryptedPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($memUnicode)

        $message = "Hello,<br>
        <br>
        Your password has been reset to <strong>{0}</strong><br>
        Please allow up to 5 minutes before using your new password to allow the systems to syncronize.<br>
        <br>
        If you encounter issues after a total of 15 minutes, please contact the <a href='mailto:ITitsupport@ITcom'>IT Support Desk</a> for assistance.
        " -f $private:decryptedPassword
        Send-TeamsChatMessage -Users $env:USERNAME, $NewPassword.UserName -Message $message
        Remove-Variable decryptedPassword -Scope Private
        'Message sent to user' | Trace-Output -Level Information
    }

    try {
        if ($PSBoundParameters.Keys -contains 'MultipleUsers') {
            'Multiple users selected, updating a ticket is not possible' | Trace-Output -Level Warning
            $prompt = Get-UserInput
            if (!$prompt) {
                throw 'Password reset cancelled'
            }
            $Identity = $MultipleUsers
        }
        
        foreach ($user in $Identity) {
            $username = getUser -Username $user
            switch ($PSBoundParameters.Keys) {
                'RandomPassword' { [PSCredential]$password = generateRandomPassword -Username $username }
                'ChangePasswordAtLogon' { changePasswordAtLogon -Username $username -ChangePasswordAtLogon $ChangePasswordAtLogon }
                'UnlockAccount' { unlockAccount -Username $username }
                Default { [PSCredential]$password = generateStandardPassword -Username $username }
            }
            setPassword -NewPassword $password
            sendPasswordToUser -NewPassword $password
            
            if ($PSBoundParameters.Keys -notcontains 'MultipleUsers') {
                $body = "
                Hello,<br>
                <br>
                {0}'s password has been reset and provided to them via Teams message.
                " -f $Username.Name
                Update-Ticket -HtmlBody $body -TicketNumber $TicketNumber
            }
        }
    }
    catch {
        Format-Exception -Exception $PSItem
    }
}