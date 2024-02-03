function Format-Exception {
    # Ensures consistent output for exceptions
    param (
        [Parameter(ValueFromPipeline)]$Exception
    )
    if ($Exception.GetType().Name -eq 'String') {
        $formattedException = $Exception
    }
    else {
        $formattedException = [ordered]@{
            Message = $Exception.Exception.Message
            LineNumber = $Exception.InvocationInfo.ScriptLineNumber
            FunctionName = (Get-PSCallStack)[1].Command
            Line = $Exception.InvocationInfo.Line.TrimStart()
        }
    }
    return $formattedException | Format-Table -AutoSize -Wrap | Out-String
}