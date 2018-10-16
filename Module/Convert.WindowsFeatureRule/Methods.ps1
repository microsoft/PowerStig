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
        $checkContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    $windowsFeatureName = @()
    try
    {
        switch ($checkContent)
        {
            { $PSItem -match $script:regularExpression.WindowsFeatureName }
            {
                $matches = $checkContent | Select-String -Pattern $script:regularExpression.WindowsFeatureName
                $windowsFeatureName += ( $matches.Matches.Value -replace 'Get-WindowsFeature\s-Name' ).Trim()
            }
            { $PSItem -match $script:regularExpression.FeatureNameEquals }
            {
                $matches = $checkContent | Select-String -Pattern $script:regularExpression.FeatureNameEquals
                $windowsFeatureName += ( $matches.Matches.Value -replace 'FeatureName\s-eq' ).Trim()
            }
            { $PSItem -match $script:regularExpression.FeatureNameSpaceColon }
            {
                $matches = $checkContent | Select-String -Pattern $script:regularExpression.FeatureNameSpaceColon -AllMatches
                $windowsFeatureName += ( $matches.Matches.Value -replace 'FeatureName\s\:' ).Trim()
            }
            { $PSItem -match $script:regularExpression.IfTheApplicationExists -and $PSItem -notmatch 'telnet' }
            {
                $matches = $checkContent | Select-String -Pattern $script:regularExpression.IfTheApplicationExists
                $windowsFeatureName += (($matches.Matches.Value | Select-String -Pattern $script:regularExpression.textBetweenQuotes).Matches.Value -replace '"').Trim()
            }
            { $PSItem -match 'telnet' }
            {
                $windowsFeatureName += 'TelnetClient'
            }
            { $PSItem -match $script:regularExpression.WebDavPublishingFeature }
            {
                $windowsFeatureName += 'Web-DAV-Publishing'
            }
            { $PSItem -match $script:regularExpression.SimpleTCP }
            {
                $windowsFeatureName += 'SimpleTCP'
            }
            { $PSItem -match $script:regularExpression.IISHostableWebCore }
            {
                $windowsFeatureName += 'IIS-HostableWebCore'
            }
            { $PSItem -match $script:regularExpression.IISWebserver }
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
        $checkContent
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
