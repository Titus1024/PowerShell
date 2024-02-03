function Test-DatabaseConnection {
    <#
    .DESCRIPTION
    Internal function to test connectivity to the logging database
#>

    try {
        [PSCredential]$credential = Get-EncryptedCredential
        $databaseSplat = @{
            DatabaseName   = $script:ITUtilities_Private.LoggingDefaults.DatabaseName
            TableName      = $script:ITUtilities_Private.LoggingDefaults.TableName
            SchemaName     = $script:ITUtilities_Private.LoggingDefaults.SchemaName
            ServerInstance = $script:ITUtilities_Private.LoggingDefaults.ServerInstance
            Credential     = $credential
        }
        [void](Get-SqlDatabase -Name $databaseSplat.DatabaseName -ServerInstance $databaseSplat.ServerInstance -Credential $databaseSplat.Credential -ErrorAction Stop)
        return $databaseSplat
    }
    catch {
        $PSItem | Format-Exception
        $script:ITUtilities_Private.LoggingDefaults.LoggingMode = 'File'
        return $false
    }
}