# function header '^function\s\w+-\w+\n\{\n\s{4}\[CmdletBinding\(\)\]\n\s{4}\[OutputType\(\['

function Find-String
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Path,

        [Parameter(Mandatory=$true)]
        [string]
        $String,

        [Parameter()]
        [string]
        $ExtensionFilter = 'ps(m)?1',

        [Parameter()]
        [switch]
        $CaseSensitive
    )

    Get-ChildItem -Path $Path -File -Recurse |
        Where-Object {$PSitem.Extension -match $ExtensionFilter} |
            Foreach-Object {

        $selectStringParam = @{
            Pattern = $String
            CaseSensitive = $CaseSensitive
        }

        $stringMatch = $PSItem | Get-Content | Select-String @selectStringParam

        if($stringMatch)
        {
            $_.FullName
            foreach ($item in $stringMatch)
            {
                "Line number :: $($item.LineNumber) :: $($item.ToString().Trim())"
                #$item | GM
                #$item.filename
            }
            ""
        }
    }
}

$path = 'C:\Users\adamh\source\repos\PowerSTIG\PowerStig'
$string = 'CompositeResourceFilter'

cls
Find-String -Path $path -String $string -ExtensionFilter '.'


#INFO: [330 of 374] V-39325

#Get-SingleLineRegistryPath

# 565
