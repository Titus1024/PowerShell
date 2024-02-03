function Connect-SharePoint {
    <#
    .DESCRIPTION
    Connects to SharePoint Online via PowerShell
    #>
    try {
        Connect-SPOService -Url 'https://it-admin.sharepoint.com' -ModernAuth:$true -ErrorAction Stop
        'Connected to SharePoint Online' | Trace-Output -Level Information
    }
    catch {
        $PSItem | Format-Exception
    }
}