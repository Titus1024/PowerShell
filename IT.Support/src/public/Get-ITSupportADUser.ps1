function Get-ITSupportADUser {
    <#
    .DESCRIPTION
    Queries AD user(s). Can display helpful properties with color coding or return an AD object that can be passed to other commands
    .PARAMETER Identity
    Supply the SamAccountName(s) for the users to query
    Supports tab auto completion
    .PARAMETER DoNotFormat
    Determines if the AD object(s) are returned intact or formatted
    .EXAMPLE
    Get-ITSupportADUser -Identity 'jdoe'
    .EXAMPLE
    Get-ITSupportADUser -Identity 'jdoe','rdoe'
    .EXAMPLE
    Get-ITSupportADUser -Identity 'jdoe','rdoe' -DoNotFormat
    .OUTPUTS
    Microsoft.ActiveDirectory.Management.ADAccount
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName = "Identity")]
        [string[]]
        $Identity,
        [Parameter(ParameterSetName = "Identity")]
        [switch]
        $DoNotFormat,
        [Parameter(Mandatory, ParameterSetName = "Filter")]
        [ValidateScript(
            {
                $json = Get-Content "$PSScriptRoot\..\config\config.json"
                $PSItem -in ($json | ConvertFrom-Json).ADFilters.Filters
            }
        )]
        [ArgumentCompleter(
            {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                $json = Get-Content "$PSScriptRoot\..\config\config.json"
                $filters = ($json | ConvertFrom-Json).ADFilters.Filters
                $filters -like "$wordToComplete*"
            }
        )]
        [string]
        $Filter
    )

    try {
        # Properties that we care about
        $objectProperties = @{
            Properties = @(
                "Name",
                "UserPrincipalName",
                "Enabled",
                "Title",
                "Department",
                "Office",
                "EmployeeNumber",
                "Company",
                "LockedOut",
                "PasswordExpired",
                "Modified",
                "Description",
                "LastLogonDate",
                "PasswordNeverExpires",
                "PasswordLastSet"
            )
        }
        if ($PSBoundParameters.Keys -contains 'Filter') {
            $getFilteredObjects = Get-ADFilter -Filter $filter -Properties $objectProperties.Properties
            return $getFilteredObjects
        }

        $adObjects = @()
        
        # Adds support for querying multiple users
        foreach ($object in $Identity) {
            $adObject = Get-ADUser -Identity $object @objectProperties
            $adObjects += $adObject
        }

        # Returns the AD object(s) intact so they can be passed to other commands
        if ($PSBoundParameters.Keys -contains 'DoNotFormat') {
            "Successfully queried {0} accounts" -f $adObjects.Count | Trace-Output -Level Verbose
            return $adObjects
        }

        # Sets up conditional color coding for output
        foreach ($adObject in $adObjects) {
            switch ($objectProperties.Properties) {
                'Name' {
                    $format = [PSCustomObject]@{
                        Message = "Name                : "
                        Object  = $adObject.Name
                    }
                    $format | Format-Output -Status Pass
                }
                'UserPrincipalName' {
                    $format = [PSCustomObject]@{
                        Message = "UserPrincipalName   : "
                        Object  = $adObject.UserPrincipalName
                    }
                    $format | Format-Output -Status Pass
                }
                'Enabled' {
                    $format = [PSCustomObject]@{
                        Message = "Enabled             : "
                        Object  = $adObject.Enabled
                    }
                    if ($adObject.Enabled -eq $false) {
                        $format | Format-Output -Status Fail
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'Title' {
                    $format = [PSCustomObject]@{
                        Message = "Title               : "
                        Object  = $adObject.Title
                    }
                    if ($null -eq $adObject.Title) {
                        $format.Object = 'Null'
                        $format | Format-Output -Status Warning
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'Department' {
                    $format = [PSCustomObject]@{
                        Message = "Department          : "
                        Object  = $adObject.Department
                    }
                    if ($null -eq $adObject.Department) {
                        $format.Object = 'Null'
                        $format | Format-Output -Status Warning
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'Office' {
                    $format = [PSCustomObject]@{
                        Message = "Office              : "
                        Object  = $adObject.Office
                    }
                    if ($null -eq $adObject.Office) {
                        $format.Object = 'Null'
                        $format | Format-Output -Status Warning
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'Company' {
                    $format = [PSCustomObject]@{
                        Message = "Company             : "
                        Object  = $adObject.Company
                    }
                    if ($null -eq $adObject.Company) {
                        $format.Object = 'Null'
                        $format | Format-Output -Status Warning
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'EmployeeNumber' {
                    $format = [PSCustomObject]@{
                        Message = "Employee Number     : "
                        Object  = $adObject.EmployeeNumber
                    }
                    if ($null -eq $adObject.EmployeeNumber) {
                        $format.Object = 'Null'
                        $format | Format-Output -Status Fail
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'LockedOut' {
                    $format = [PSCustomObject]@{
                        Message = "LockedOut           : "
                        Object  = $adObject.LockedOut
                    }
                    if ($true -eq $adObject.LockedOut) {
                        $format | Format-Output -Status Fail
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'PasswordExpired' {
                    $format = [PSCustomObject]@{
                        Message = "PasswordExpired     : "
                        Object  = $adObject.PasswordExpired
                    }
                    if ($true -eq $adObject.PasswordExpired) {
                        $format | Format-Output -Status Fail
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'Modified' {
                    $format = [PSCustomObject]@{
                        Message = "Modified            : "
                        Object  = $adObject.Modified
                    }
                    if ($adObject.Modified -gt (Get-Date).AddHours(-1)) {
                        $format | Format-Output -Status Warning
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'Description' {
                    if ($null -eq $adObject.Description) {
                        $format.Object = 'Null'
                        $format | Format-Output -Status Warning
                        continue
                    }
                    $format = [PSCustomObject]@{
                        Message = "Description         : "
                        Object  = ($adObject.Description | Split-TextOnLineWidth -Width 100 -PaddingLeft 22)
                    }
                    $format | Format-Output -Status Pass
                }
                'LastLogonDate' {
                    $format = [PSCustomObject]@{
                        Message = "LastLogonDate       : "
                        Object  = $adObject.LastLogonDate
                    }
                    if ($adObject.LastLogonDate -lt (Get-Date).AddDays(-15)) {
                        $format | Format-Output -Status Warning
                        continue
                    }
                    if ($adObject.LastLogonDate -lt (Get-Date).AddDays(-30)) {
                        $format | Format-Output -Status Fail
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'PasswordNeverExpires' {
                    $format = [PSCustomObject]@{
                        Message = "PasswordNeverExpires: "
                        Object  = $adObject.PasswordNeverExpires
                    }
                    if ($adObject.PasswordNeverExpires -eq $true) {
                        $format | Format-Output -Status Fail
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
                'PasswordLastSet' {
                    $format = [PSCustomObject]@{
                        Message = "PasswordLastSet     : "
                        Object  = $adObject.PasswordLastSet
                    }
                    [int]$passwordExpiration = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
                    if (($passwordExpiration - ((Get-Date) - $adObject.PasswordLastSet).Days) -lt 5) {
                        $format | Format-Output -Status Warning
                        continue
                    }
                    $format | Format-Output -Status Pass
                }
            }
            "{0} successfully queried" -f $adObject.Name | Trace-Output -Level Verbose
            # Adds a separator between outputs
            Write-Host ''
        }
    }
    catch {
        Format-Exception -Exception $PSItem
    }
}