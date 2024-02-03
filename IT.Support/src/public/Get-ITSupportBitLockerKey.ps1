function Get-ITSupportBitLockerKey {
    <#
    .DESCRIPTION
    Returns the BitLocker unlock token for a computer. Requires user validation via employee number
    .PARAMETER ComputerName
    Name of the computer that requires the unlock token
    .PARAMETER Identity
    Username of the individual requesting the unlock token
    .PARAMETER Validation
    Employee number of the individual requesting the unlock token. The provided number must match the users employee number to pass validation
    .EXAMPLE
    Get-ITSupportBitLockerKey -ComputerName CO22415L07 -Identity jdoe -Validation 123456
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ComputerName,
        [Parameter(Mandatory)]
        [string]
        $Identity,
        [Parameter(Mandatory)]
        [string]
        $Validation
    )

    try {
        $computerObject = Get-ADComputer -Identity $ComputerName -ErrorAction Stop
        if ($computerObject.Enabled -ne $true) {
            throw "{0} is disabled in ActiveDirectory" -f $ComputerName
        }

        $userValidation = Get-ITSupportADUser -Identity $Identity -DoNotFormat
        if ($userValidation.EmployeeNumber -ne $Validation) {
            throw "{0} does not match {1}'s employee number" -f $Validation, $userValidation.Name
        }

        $key = Get-ADObject -Filter "objectClass -eq 'msFVE-RecoveryInformation'" -SearchBase $computerObject.DistinguishedName -Properties msFVE-RecoveryPassword, whenCreated -ErrorAction Stop | Sort-Object whenCreated -Descending | Select-Object -First 1
        $keyInfo = [PSCustomObject]@{
            ComputerName      = $computerObject.Name
            BitLockerPassword = $key.'msFVE-RecoveryPassword'
            Created           = $key.WhenCreated
        }

        "Successfully retrieved BitLocker unlock key for {0}" -f $ComputerName | Trace-Output -Level Information
        return $keyInfo
    }
    catch {
        $PSItem | Format-Exception
    }
}

<#
$a
$computer = Get-ADComputer (hostname)
$key = Get-ADObject -Filter "objectClass -eq 'msFVE-RecoveryInformation'" -SearchBase $Computer.distinguishedName -Properties msFVE-RecoveryPassword, whenCreated | Sort-Object whenCreated -Descending | Select-Object -First 1
$info = [PSCustomObject]@{
    ComputerName         = $Computer.Name
    BitLockerPassword = $key.'msFVE-RecoveryPassword'
    Created = $key.WhenCreated
}

$info
#>