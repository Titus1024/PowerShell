function Split-TextOnLineWidth {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $Text,
        [ValidateScript({
                $PSItem -le $Host.UI.RawUI.BufferSize.Width
            })]
        [int]
        $Width = $Host.UI.RawUI.BufferSize.Width,
        [int]
        $PaddingLeft
    )

    process {
        foreach ($textInput in $Text) {
            $column = 0
            $output = [Text.StringBuilder]::new()

            foreach ($word in $textInput.Split(' ')) {
                $column += $word.Length + 1

                if ($column -gt $Width) {
                    [void] $output.Append(("`n" + " " * $PaddingLeft + "$word "))
                    $column = $word.Length + 1
                }
                else {
                    [void] $output.Append("$word ")
                }
            }

            $output.ToString()
        }
    }
}