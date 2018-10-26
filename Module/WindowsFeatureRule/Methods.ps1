# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retreives the WindowsFeature name from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-WindowsFeatureName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    $windowsFeatureName = @()
    try
    {
        switch ($checkContent)
        {
            { $PSItem -match $regularExpression.WindowsFeatureName }
            {
                $matches = $checkContent | Select-String -Pattern $regularExpression.WindowsFeatureName
                $windowsFeatureName += ( $matches.Matches.Value -replace 'Get-WindowsFeature\s-Name' ).Trim()
            }
            { $PSItem -match $regularExpression.FeatureNameEquals }
            {
                $matches = $checkContent | Select-String -Pattern $regularExpression.FeatureNameEquals
                $windowsFeatureName += ( $matches.Matches.Value -replace 'FeatureName\s-eq' ).Trim()
            }
            { $PSItem -match $RegularExpression.FeatureNameSpaceColon }
            {
                $matches = $checkContent | Select-String -Pattern $RegularExpression.FeatureNameSpaceColon -AllMatches
                $windowsFeatureName += ( $matches.Matches.Value -replace 'FeatureName\s\:' ).Trim()
            }
            { $PSItem -match $RegularExpression.IfTheApplicationExists -and $PSItem -notmatch 'telnet' }
            {
                $matches = $checkContent | Select-String -Pattern $RegularExpression.IfTheApplicationExists
                $windowsFeatureName += (($matches.Matches.Value | Select-String -Pattern ([RegularExpression]::TextBetweenQuotes)).Matches.Value -replace '"').Trim()
            }
            { $PSItem -match 'telnet' }
            {
                $windowsFeatureName += 'TelnetClient'
            }
            { $PSItem -match $RegularExpression.WebDavPublishingFeature }
            {
                $windowsFeatureName += 'Web-DAV-Publishing'
            }
            { $PSItem -match $RegularExpression.SimpleTCP }
            {
                $windowsFeatureName += 'SimpleTCP'
            }
            { $PSItem -match $RegularExpression.IISHostableWebCore }
            {
                $windowsFeatureName += 'IIS-HostableWebCore'
            }
            { $PSItem -match $RegularExpression.IISWebserver }
            {
                $windowsFeatureName += 'IIS-WebServer'
            }
        }
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] WindowsOptionalFeature : Not Found"
        return $null
    }
    return ($windowsFeatureName -join ',')
}

<#
    .SYNOPSIS
        Retreives the WindowsFeature InstallState from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-FeatureInstallState
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        <#
            Currently ALL WindowsFeatureRules referenced in any of the STIGs will be uninstalled (Absent)
            so the default is Absent. When a STIG rule states a WindowsFeature is to be installed (Present)
            we can add the logic here.
        #>
        { $PSItem -eq $false }
        {
            return [ensure]::Present
        }
        default
        {
            [ensure]::Absent
        }
    }
}

<#
    .SYNOPSIS
        Test if the check-content contains WindowsFeatures to install/uninstall.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Test-MultipleWindowsFeatureRule
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $FeatureName
    )

    if ( $FeatureName -match ',')
    {
        return $true
    }
    return $false
}

<#
    .SYNOPSIS
        Consumes a list of mitigation targets seperated by a comma and outputs an array

    .PARAMETER FeatureName
        A list of comma seperate WindowsFeature names
#>
function Split-WindowsFeatureRule
{
    [CmdletBinding()]
    [OutputType([array])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $FeatureName
    )

    return ( $FeatureName -split ',' )
}
#endregion
