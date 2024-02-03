function Update-Ticket {
    # Simplifies the process of updating a ticket via email
    param(
        $HtmlBody,
        $TicketNumber
    )
    try {
        $subject = "Request : ##RE-$TicketNumber##"
        Send-Email -Subject $subject -Body $HtmlBody -To $to
        "Ticket `#{0} has been updated" -f $TicketNumber | Trace-Output -Level Information
    }
    catch {
        Format-Exception -Exception $PSItem
    }
}