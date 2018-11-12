# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Main Functions
<#
    .SYNOPSIS
        Looks in the Check-Content element to see if it matches registry string.

    .PARAMETER CheckStrings
        Check-Content element
#>
function Test-SingleLineRegistryRule
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    if ($checkContent -match "(HKCU|HKLM|HKEY_LOCAL_MACHINE)\\")
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] $true"
        $true
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] $false"
        $false
    }
}
#endregion
#region Registry Path
<#
    .SYNOPSIS
        Extract the registry path from an office STIG string.

    .Parameter CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-SingleLineRegistryPath
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $fullRegistryPath = $checkContent | Select-String -Pattern "((HKLM|HKCU|HKEY_LOCAL_MACHINE|HKEY_CURRENT_USER).*)"

    if (-not $fullRegistryPath)
    {
        return
    }

    if ($fullRegistryPath.ToString().Contains("Criteria:"))
    {
        if ($fullRegistryPath.ToString() -match "((HKLM|HKCU).*(?=Criteria:))")
        {
            $fullRegistryPath = $fullRegistryPath.ToString() | Select-String -Pattern "((HKLM|HKCU).*(?=Criteria:))"
        }
        elseif ($fullRegistryPath.ToString() -match "Criteria:.*(HKLM|HKCU)")
        {
            $fullRegistryPath = $fullRegistryPath.ToString() | Select-String -Pattern "((HKLM|HKCU).*(?=\sis))"
        }
    }
    if ($fullRegistryPath.ToString().Contains("Verify"))
    {
        $fullRegistryPath = $fullRegistryPath.ToString() | Select-String -Pattern "((HKLM|HKCU).*(?=Verify))"
    }
    if ($fullRegistryPath.ToString().Contains("NETFramework"))
    {
        $fullRegistryPath = $fullRegistryPath.ToString() | Select-String -Pattern "((HKLM|HKCU|HKEY_LOCAL_MACHINE).*(?=key))"
    }
    if ($fullRegistryPath.Count -gt 1 -and $fullRegistryPath[0] -match 'outlook\\security')
    {
        $fullRegistryPath = $fullRegistryPath[1].ToString() | Select-String -Pattern "((HKLM|HKCU).*\\security)"
    }
    if ($fullRegistryPath.ToString() -match "the value for hkcu.*Message\sPlain\sFormat\sMime")
    {
        $fullRegistryPath = $fullRegistryPath.ToString() | Select-String -Pattern "((HKLM|HKCU).*(?=\sis))"
    }

    $fullRegistryPath = $fullRegistryPath.Matches.Value

    if ( -not [String]::IsNullOrEmpty( $fullRegistryPath ) )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]   Found path : $true"

        switch -Wildcard ($fullRegistryPath)
        {
            "*HKLM*" {$fullRegistryPath = $fullRegistryPath -replace "^HKLM", "HKEY_LOCAL_MACHINE"}

            "*HKCU*" {$fullRegistryPath = $fullRegistryPath -replace "^HKCU", "HKEY_CURRENT_USER"}

            "*Software Publishing Criteria" {$fullRegistryPath = $fullRegistryPath -replace 'Software Publishing Criteria$','Software Publishing'}
        }

        $fullRegistryPath = $fullRegistryPath.ToString().trim(' ', '.')

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Trimmed path : $fullRegistryPath"
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]   Found path : $false"
        throw "Registry path was not found in check content."
    }

    return $fullRegistryPath
}
#endregion
#region Registry Type
<#
    .SYNOPSIS
        Extract the registry value type from an Office STIG string.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryValueTypeFromSingleLineStig
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    try
    {
        $valueName = Get-RegistryValueNameFromSingleLineStig -CheckContent $checkContent
    }
    catch
    {
        return
    }

    $valueName = [Regex]::Escape($valueName)

    $valueType = $checkContent | Select-String -Pattern "(?<=$valueName(\"")? is not ).*="

    if (-not $valueType)
    {
        $valueType = $checkContent | Select-String -Pattern "(?<=$valueName(\"")?\s+is ).*="
    }

    if (-not $valueType)
    {
        $valueType = $checkContent | Select-String -Pattern "(?<=Verify\sa).*(?=value\sof)"
    }

    if (-not $valueType)
    {
        $valueType = ($checkContent | Select-String -Pattern 'registry key exists and the([\s\S]*?)value')
        if ($valueType)
        {
            $valueType = $valueType.Matches.Groups[1].Value
        }
    }

    if (-not $valueType)
    {
        $valueType = $checkContent | Select-String -Pattern "(?<=$valueName`" is set to ).*`""
    }

    if (-not $valueType)
    {
        $valueType = $checkContent | Select-String -Pattern "((hkcu|hklm).*\sis\s(.*)=)"

        if ($valueType)
        {
            $valueType = $valueType.Matches.Groups[3].Value
        }
    }

    if (-not $valueType)
    {
        $valueType = $checkContent | Select-String -Pattern '((?<=If the\s)(.*)(?<=DWORD))'
    }

    if (-not $valueType)
    {
        if ($checkContent | Select-String -Pattern "exists, this is a finding")
        {
            return "Does Not Exist"
        }
        $valueType = ""
    }

    if (-not $valueType)
    {
        if ($checkContent | Select-String -Pattern "does not exist, this is not a finding")
        {
            return "Does Not Exist"
        }
        $valueType = ""
    }

    if (-not $valueType)
    {
        if ($checkContent | Select-String -Pattern "with entries, this is a finding")
        {
            return "Does Not Exist"
        }
        $valueType = ""
    }

    if ($valueType -is [Microsoft.PowerShell.Commands.MatchInfo])
    {
        $valueType = $valueType.Matches.Value.Replace('=', '').Replace('"', '')
    }

    if ( -not [String]::IsNullOrWhiteSpace( $valueType.Trim() ) )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]    Found Type : $valueTypetype"

        $valueType = Test-RegistryValueType -TestValueType $valueType
        $return = $valueType.trim()

        Write-Verbose "[$($MyInvocation.MyCommand.Name)]  Trimmed Type : $valueType"
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]   Found Type : $false"
        # If we get here, there is nothing to verify so return.
        return
    }

    $return
}
#endregion
#region Registry Name
<#
    .SYNOPSIS
        Extract the registry value type from a string.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryValueNameFromSingleLineStig
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $valueName = $checkContent | Select-String -Pattern '(?<=If the value(\s*)?((for( )?)?)").*(")?((?=is.*R)|(?=does not exist))'

    if (-not $valueName)
    {
        if ($checkContent -match 'If the.+(registry key does not exist)')
        {
            $valueName = $checkContent | Select-String -Pattern '"[\s\S]*?"' | Select-Object -First 1
        }
    }

    if (-not $valueName)
    {
        if ($checkContent -match 'If the REG_DWORD')
        {
            $valueName = $checkContent | Select-String -Pattern '((?<=for\s")(.*)(?<="))'
        }
    }

    if (-not $valueName)
    {
        $valueName = $checkContent | Select-String -Pattern '(?<=If the value of\s")(.*)(?="\s.*R)|(?=does not exist)'
    }

    if (-not $valueName)
    {
        $valueName = $checkContent | Select-String -Pattern '((?<=If the value\s)(.*)(?=is\sR))'
    }

    if ($valueName)
    {
        if ($checkContent -match 'a value of between')
        {
            $valueName = $checkContent | Select-String -Pattern '((?<=gs\\)(.*)(?<=Len\s))'
        }
    }

    if (-not $valueName)
    {
        if ($checkContent -match 'FileExtensionsRemoveLevel')
        {
            $valueName = $checkContent | Select-String -Pattern '((?<=the registry value\s.)(.*)(?=.\We))'
        }
    }

    if (-not $valueName)
    {
        if ($checkContent -match 'the policy value')

        {
            $valueName = $checkContent | Select-String -Pattern '(?<=ty\\)(.*)(?<=)'
        }
        else
        {
            $valueName = $checkContent | Select-String -Pattern '(?<=")(.*)(?="\sis)'
        }
    }

    if (-not $valueName)
    {
        $valueName = $checkContent | Select-String -Pattern '((?<=for\s).*)'
    }

    if ($valueName)
    {
        if ($checkContent -match 'Message Plain Format')
        {
            $valueName = $checkContent | Select-String -Pattern '((?<=il\\)(.*)(?<=e\s))'
        }
    }

    if (-not $valueName)
    {
        $valueName = $checkContent | Select-String -Pattern "(?<=filevalidation\\).*(?=\sis\sset\sto)"
    }

    $valueName = $valueName.Matches.Value.Replace('"', '')

    if ($valueName.Count -gt 1)
    {
        $valueName = $valueName[0]
    }

    if ( -not [String]::IsNullOrEmpty( $valueName ) )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]   Found Name : $valueName"

        $return = $valueName.trim()

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Trimmed Name : $valueName"
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]   Found Name : $false"
        return
    }

    $return
}
#endregion
#region Registry Data
<#
    .SYNOPSIS
        Looks for multiple patterns in the value string to extract out the value to return or determine
        if additional processing is required. For example if an allowable range detected, additional
        functions need to be called to convert the text into powershell operators.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryValueDataFromSingleStig
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    try
    {
        $valueType = Get-RegistryValueTypeFromSingleLineStig -CheckContent $checkContent
    }
    catch
    {
        return
    }

    if ($valueType -eq "Does Not Exist")
    {
        return
    }

    $valueData = $checkContent | Select-String -Pattern "(?<=$($valueType)(\s*)?=).*(?=(,|\())"

    if (-not $valueData)
    {
        $valueData = $checkContent | Select-String -Pattern "((?<=value\sof).*(?=for))"
    }

    if ($valueData)
    {
    if ($checkContent -match 'If the value PublishCalendarDetailsPolicy')
        {
            $valueData = $checkContent | Select-String -Pattern "((?<=is\s)(.*)(?=\sor))"
        }
    }

    if (-not $valueData)
    {
        $valueData = $checkContent | Select-String -Pattern "((?<=set\sto).*(?=\(true\)))"
    }

    if (-not $valueData)
    {
        $valueData = $checkContent | Select-String -Pattern "((?<=is\sset\sto\s)(`'|`")).*(?=(`'|`"))"
    }

    if (-not $valueData)
    {
        $valueData = $checkContent | Select-String -Pattern "(?<=$($valueType)\s=).*"
    }

    $valueData = $valueData.Matches.Value.Replace(',', '').Replace('"', '')

    if ( -not [String]::IsNullOrEmpty( $valueData ) )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]   Found Name : $valueData"

        $return = $valueData.trim(" ", "'")

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Trimmed Name : $return"
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]   Found Name : $false"
        return
    }

    $return
}
#endregion
#region Ancillary functions
<#
    .SYNOPSIS
        Get the registry value string from the Office STIG format.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.

    .Parameter Trim
        Trims the leading a trailing parts of the string that are not registry specific
#>
function Get-RegistryValueStringFromSingleLineStig
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent,

        [Parameter()]
        [switch]
        $Trim
    )

    [string] $registryLine = ( $checkContent | Select-String -Pattern "Criteria:")

    if ( -not [String]::IsNullOrEmpty( $registryLine ) )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]   Found Value : $true"
        $return = $registryLine.trim()
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]   Found Value : $false"
        return
    }

    if ($trim)
    {
        <#
            Trim leading and trailing string that is not needed.
            Criteria: If the value of excel.exe is REG_DWORD = 1, this is not a finding.
            Criteria: If the value SomeValueNAme is REG_DWORD = 1, this is not a finding.
        #>
        $return = (
            $return -Replace "Criteria: If the value (of)*\s*|\s*,\s*this is not a finding.", ''
        )

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Trimmed Value : $return"
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Trimmed Value : $return"
    }

    # The string returned from here is split on the space, so remove extra spaces.
    $return -replace "\s{2,}", " "
}

<#
    .SYNOPSIS
        Checks the registry string format to determine if it is in the Office STIG format.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Test-SingleLineStigFormat
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    if ($checkContent -match "HKLM|HKCU|HKEY_LOCAL_MACHINE\\")
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] $true"
        $true
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] $false"
        $false
    }
}
#endregion
