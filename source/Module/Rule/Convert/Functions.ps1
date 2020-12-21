# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# These are the registry strings that are not able to be automatically extracted from the xccdf.
$script:legalNoticeText = 'You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.

By using this IS (which includes any device attached to this IS), you consent to the following conditions:

-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.

-At any time, the USG may inspect and seize data stored on this IS.

-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.

-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.

-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details.'
$script:legalNoticeCaption = 'DoD Notice and Consent Banner'
$script:supportedEncryptionTypes = '0'
$script:smb1FeatureName = 'FS-SMB1'
$script:publishersCertificateRevocation = '146432'

<#
    .SYNOPSIS
        Accepts defeat in that the STIG string data for a select few checks are too unwieldy to parse
        properly. The OVAL data does not provide much more help in a few of the cases, so the STIG Id's
        for these checks are hardcoded here to force a fixed value to be returned.

    .PARAMETER StigId
        The Stig ID to check for a fixed string
#>
function Test-ValueDataIsHardCoded
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $StigId
    )

    $stigIds = @(
        'V-1089', # Windows Server 2012R2 - Legal Notice Display
        'V-225465', # Windows Server 2012R2 (MS) - Legal Notice Display
        'V-226288', # Windows Server 2012R2 (DC) - Legal Notice Display
        'V-73647', # Windows Server 2016 - Legal Notice Display
        'V-225036', # Windows Server 2016 - Legal Notice Display
        'V-93147', # Windows Server 2019 - Legal Notice Display
        'V-205631', # Windows Server 2019 - Legal Notice Display
        'V-63675', # Windows Client - Legal Notice Display
        'V-220921', # Windows Client - Legal Notice Display
        'V-26359', # Windows Server 2012R2 - Legal Banner Dialog Box Title
        'V-225466', # Windows Server 2012R2 (MS) - Legal Banner Dialog Box Title
        'V-226289', # Windows Server 2012R2 (DC) - Legal Banner Dialog Box Title
        'V-73649', # Windows Server 2016 - Legal Banner Dialog Box Title
        'V-225037', # Windows Server 2016 - Legal Banner Dialog Box Title
        'V-93149', # Windows Server 2019 - Legal Banner Dialog Box Title
        'V-205632', # Windows Server 2019 - Legal Banner Dialog Box Title
        'V-63681', # Windows Client - Legal Banner Dialog Box Title
        'V-220922' # Windows Client - Legal Banner Dialog Box Title
    )

    if ($stigIds -contains $stigId)
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] HardCoded : $true"
        $true
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] HardCoded : $false"
        $false
    }
}

<#
    .SYNOPSIS
        Returns the hard coded string for the given Stig ID

    .PARAMETER StigId
        The Stig ID to check for a fixed string
 #>
function Get-HardCodedString
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $StigId
    )

    switch ($stigId)
    {
        {$PSItem -match 'V-1089|V-63675|V-73647|V-93147|V-225465|V-226288|V-205631|V-220921|V-225036'}
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] LegalNotice : $true"
            return $script:legalNoticeText
        }
        {$PSItem -match 'V-26359|V-63681|V-73649|V-93149|V-225466|V-226289|V-225037|V-220922'}
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] LegalCaption : $true"
            return $script:legalNoticeCaption
        }
    }
}

<#
    .SYNOPSIS
        Determines if the organization value test string is in the short list of STIGs that
        cannot be reasonably parsed

    .PARAMETER StigId
        The Stig ID to check for a fixed string
 #>
 function Test-IsHardCodedOrganizationValueTestString
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $StigId
    )

    $stigIds = @(
        'V-3472.b', # Windows Time Service - Configure NTP Client
        'V-225361.b' # Windows Time Service - Configure NTP Client
        'V-8322.b', # Time Synchronization
        'V-226076.b', # Time Synchronization (2012 R2 DC)
        'V-14235', # UAC - Admin Elevation Prompt
        'V-225516', # UAC - Admin Elevation Prompt (2012 R2 MS)
        'V-226339', # UAC - Admin Elevation Prompt (2012 R2 DC)
        'V-26359', # Windows Server 2012R2 - Legal Banner Dialog Box Title
        'V-225466', # Windows Server 2012R2 (MS) - Legal Banner Dialog Box Title
        'V-226289', # Windows Server 2012R2 (DC) - Legal Banner Dialog Box Title
        'V-73649', # Windows Server 2016 - Legal Banner Dialog Box Title
        'V-225037', # Windows Server 2016 - Legal Banner Dialog Box Title
        'V-93149', # Windows Server 2019 - Legal Banner Dialog Box Title
        'V-205632', # Windows Server 2019 - Legal Banner Dialog Box Title
        'V-63681', # Windows 10 Client - Legal Banner Dialog Box Title
        'V-220922' # Windows 10 Client - Legal Banner Dialog Box Title
    )

    if ($stigIds -contains $stigId)
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] HardCoded : $true"
        $true
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] HardCoded : $false"
        $false
    }
}

<#
    .SYNOPSIS
        Returns the hard coded organization value test string for the given Stig ID

    .PARAMETER StigId
        The Stig ID to check for a fixed string
 #>
 function Get-HardCodedOrganizationValueTestString
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $StigId
    )

    switch ($stigId)
    {
        {$PSItem -match 'V-3472.b|V-225361.b'}
        {
            $hardCodedString = "'{0}' -notmatch 'time.windows.com'"
            continue
        }
        {$PSItem -match 'V-8322.b|V-226076.b'}
        {
            $hardCodedString = "'{0}' -match '^(NoSync|NTP|NT5DS|AllSync)$'"
            continue
        }
        {$PSItem -match 'V-14235|V-225516|V-226339'}
        {
            $hardCodedString = "'{0}' -le '4'"
            continue
        }
        {$PSItem -match 'V-26359|V-73649|V-93149|V-63681|V-225466|V-226289|V-205632|V-220922|V-225037'}
        {
            $hardCodedString = "'{0}' -match '^(DoD Notice and Consent Banner|US Department of Defense Warning Statement)$'"
            continue
        }
    }

    return $hardCodedString
}

<#
    .SYNOPSIS
        Returns the RuleType from the modified check content.
    .PARAMETER CheckContent
        The HardCodedRule modified rule text from the check-content
        element in the xccdf.
#>
function Get-HardCodedRuleType
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    $hardCodedRuleTypeRegExPattern = '(?<RuleType>(?<=\().+?(?=\)))'
    $ruleTypeMatch = [regex]::Match($CheckContent, $hardCodedRuleTypeRegExPattern)
    return $ruleTypeMatch.Groups.Item('RuleType').Value
}

<#
    .SYNOPSIS
        Returns the RuleType from the modified check content.
    .PARAMETER CheckContent
        The HardCodedRule modified rule text from the check-content
        element in the xccdf.
#>

function Get-HardCodedRuleProperty
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    $hardCodedHashtableRegExPattern = '(?<hashtable>(@\{).*(\}))'
    $ruleTypeHashtable = [regex]::Match($CheckContent, $hardCodedHashtableRegExPattern)
    $scriptblockString = $ruleTypeHashtable.Groups.Item('hashtable').Value
    return [scriptblock]::Create($scriptblockString).Invoke()
}

<#
    .SYNOPSIS
        Splits and returns rule(s) from the modified check content.
    .PARAMETER CheckContent
        The HardCodedRule modified rule text from the check-content
        element in the xccdf.
#>
function Split-HardCodedRule
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    return $CheckContent -split '\<splitRule\>'
}
