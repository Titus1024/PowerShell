function Send-Email {
    # Used as a baseline for sending different emails
    param (
        $Subject,    
        $Body,
        $To,
        $Cc
    )
    try {
        $mailConfig = @{
            Subject    = $Subject
            Body       = $Body
            From       = 'noreply@ITcom'
            To         = 'ITassist@ITcom'
            SMTPServer = 'us-smtp-outbound-1.mimecast.com'
            BodyAsHtml = $true
        }
        if (![string]::IsNullOrEmpty($Cc)) {
            $optionalCc = @{
                Cc = $Cc
            }
            Send-MailMessage @mailConfig @optionalCc -ErrorAction Stop
        }
        else {
            Send-MailMessage @mailConfig -ErrorAction Stop
        }
    }
    catch {
        Format-Exception -Exception $PSItem
    }
}