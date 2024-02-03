function Test-VPNConnection {
    # Tests the connection to the
    try {
        $domainController = Get-ADDomainController -DomainName $ITUtilities_Private.Config.Domain -Discover -ErrorAction Stop
        $testConnection = Test-Connection -ComputerName $domainController.Name -Count 1 -Quiet
        return $testConnection
    }
    catch {
        $format = [PSCustomObject]@{
            Message = 'Test-VPNConnection: '
            Object = 'Fail'
        }
        $format | Format-Output -Status Fail
        return $false
    }
}