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
        switch ($CheckContent)
        {
            { $PSItem -match $script:commonRegEx.WindowsFeatureName }
            {
                $matches = $CheckContent | Select-String -Pattern $script:commonRegEx.WindowsFeatureName
                $windowsFeatureName += ( $matches.Matches.Value -replace 'Get-WindowsFeature\s-Name' ).Trim()
            }
            { $PSItem -match $script:commonRegEx.FeatureNameEquals }
            {
                $matches = $CheckContent | Select-String -Pattern $script:commonRegEx.FeatureNameEquals
                $windowsFeatureName += ( $matches.Matches.Value -replace 'FeatureName\s-eq' ).Trim()
            }
            { $PSItem -match $script:commonRegEx.FeatureNameSpaceColon }
            {
                $matches = $CheckContent | Select-String -Pattern $script:commonRegEx.FeatureNameSpaceColon -AllMatches
                $windowsFeatureName += ( $matches.Matches.Value -replace 'FeatureName\s\:' ).Trim()
            }
            { $PSItem -match $script:commonRegEx.IfTheApplicationExists -and $PSItem -notmatch 'telnet' }
            {
                $matches = $CheckContent | Select-String -Pattern $script:commonRegEx.IfTheApplicationExists
                $windowsFeatureName += (($matches.Matches.Value | Select-String -Pattern $script:commonRegEx.textBetweenQuotes).Matches.Value -replace '"').Trim()
            }
            { $PSItem -match 'telnet' }
            {
                $windowsFeatureName += 'TelnetClient'
            }
            { $PSItem -match $script:commonRegEx.WebDavPublishingFeature }
            {
                $windowsFeatureName += 'Web-DAV-Publishing'
            }
            { $PSItem -match $script:commonRegEx.SimpleTCP }
            {
                $windowsFeatureName += 'SimpleTCP'
            }
            { $PSItem -match $script:commonRegEx.IISHostableWebCore }
            {
                $windowsFeatureName += 'IIS-HostableWebCore'
            }
            { $PSItem -match $script:commonRegEx.IISWebserver }
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

    switch ($CheckContent)
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
