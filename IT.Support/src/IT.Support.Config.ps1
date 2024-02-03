# Configs here
enum TraceLevel {
    Verbose
    Information
    Warning
    Exception
}

$getConfig = Get-Content "$PSScriptRoot\config\config.json"
#$getConfig = Get-Content "C:\AzureDevOps\PowerShell\Modules\ItInc.Support\src\config\config.json"
$config = $getConfig | ConvertFrom-Json

New-Variable ITUtilities_Private -Scope Script -Force -Value @{
    Cache           = @{
        WorkingDirectory = $null
        TraceOutputFile  = $null
    }
    Config          = @{
        ComputerOU            = $config.PrivateVariables.ComputerOU
        DisabledUsersOU       = $config.PrivateVariables.DisabledUsersOU
        Domain                = $config.PrivateVariables.Domain
        RequiredModules       = $config.PrivateVariables.RequiredModules
        ServiceAccountOU      = $config.PrivateVariables.ServiceAccountOU
        SMTPServer            = $config.PrivateVariables.SMTPServer
        SyncedDisabledUsersOU = $config.PrivateVariables.SyncedDisabledUsersOU
        UserOU                = $config.PrivateVariables.UserOU
    }
    LoggingDefaults = @{
        Level            = $config.LoggingVariables.DefaultLoggingLevel
        LoggingMode      = $config.LoggingVariables.DefaultLoggingMode
        DatabaseName     = $config.LoggingVariables.DatabaseName
        ServerInstance   = $config.LoggingVariables.ServerInstance
        TableName        = $config.LoggingVariables.TableName
        SchemaName       = $config.LoggingVariables.SchemaName
        Credential       = $config.LoggingVariables.Credential
        ConnectionConfig = $null
    }
}

# Default parameter values
$Global:PSDefaultParameterValues = @{
    "Add-ItIncSupportMailboxMember:AccessRights"            = "FullAccess"
    "Convert-ItIncSupportMailbox:Type"                      = "Shared"
    "Start-ItIncSupportADUserAudit:InactiveThresholdInDays" = 30
}