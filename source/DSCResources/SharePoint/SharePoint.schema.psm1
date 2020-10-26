# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage the SharePoint STIG settings.
    .PARAMETER SharePointVersion
        The version of SharePoint being used E.g. '2013'
    .PARAMETER SPLogLevelItems
        A hashtable of SPLogLevels within an array to configure the Area and Category within ULS logs

        $SPLogLevelItem = @(@{"Area" = "SharePoint Server";"Name" = "Database";"TraceLevel" = "Verbose";"EventLevel" = "Error"},
            @{"Area" = "Business Connectivity Services";"Name" = "Business Data";"TraceLevel" = "Verbose";"EventLevel" = "Information"},
            @{"Area" = "Search";"Name" = "Content Processing";"TraceLevel" = "Verbose";"EventLevel" = "Error"}
        )
    .PARAMETER SPAlternateUrlItem
        A hashtable to configure Alternate Url on Web Applications

        $SPAlternateUrlItem = @{Url = "https://Other.contoso.com"; WebAppName = "Other web App"; Zone = "Internet"; Internal = $false}
    .PARAMETER WebAppUrlandBlockedFileTypesList
        A hashtable of Web App Url and Blocked File Types within an array to configure Blocked File Types on any Web App that you want

        $WebAppUrlandBlockedFileTypesList = @(@{"WebAppUrl" = "https://other.contoso.com";"List" = @("txt", "exe", "dll")},
            @{"WebAppUrl" = "prod.contoso.com";"List" = @("txt", "exe", "msi")},
            @{"WebAppUrl" = "test.contoso.com";"List" = @("txt", "exe", "msi")}
        )
    .PARAMETER CipherSuitesOrder
        An array of ciphers to be applied to your server

        $CipherSuitesOrder = @("TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_DHE_RSA_WITH_AES_256_GCM_SHA384","TLS_DHE_RSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256","TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384","TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256","TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA","TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA","TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA","TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA","TLS_DHE_RSA_WITH_AES_256_CBC_SHA","TLS_DHE_RSA_WITH_AES_128_CBC_SHA","TLS_RSA_WITH_AES_256_GCM_SHA384","TLS_RSA_WITH_AES_128_GCM_SHA256","TLS_RSA_WITH_AES_256_CBC_SHA256","TLS_RSA_WITH_AES_128_CBC_SHA256","TLS_RSA_WITH_AES_256_CBC_SHA","TLS_RSA_WITH_AES_128_CBC_SHA","TLS_RSA_WITH_3DES_EDE_CBC_SHA","TLS_DHE_DSS_WITH_AES_256_CBC_SHA256","TLS_DHE_DSS_WITH_AES_128_CBC_SHA256","TLS_DHE_DSS_WITH_AES_256_CBC_SHA","TLS_DHE_DSS_WITH_AES_128_CBC_SHA","TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA","TLS_RSA_WITH_RC4_128_SHA","TLS_RSA_WITH_RC4_128_MD5","TLS_RSA_WITH_NULL_SHA256","TLS_RSA_WITH_NULL_SHA")
    .PARAMETER StigVersion
        The version of the SharePoint STIG to apply and/or monitor
    .PARAMETER Exception
        A hashtable of StigId=Value key pairs that are injected into the STIG data and applied to
        the target node. The title of STIG settings are tagged with the text ‘Exception’ to identify
        the exceptions to policy across the data center when you centralize DSC log collection.
    .PARAMETER OrgSettings
        The path to the xml file that contains the local organizations preferred settings for STIG
        items that have allowable ranges.  The OrgSettings parameter also accepts a hashtable for
        values that need to be modified.  When a hashtable is used, the specified values take
        presidence over the values defined in the org.default.xml file.
    .PARAMETER SkipRule
        The SkipRule Node is injected into the STIG data and applied to the taget node. The title
        of STIG settings are tagged with the text 'Skip' to identify the skips to policy across the
        data center when you centralize DSC log collection.
    .PARAMETER SkipRuleType
        All STIG rule IDs of the specified type are collected in an array and passed to the Skip-Rule
        function. Each rule follows the same process as the SkipRule parameter.
#>

configuration SharePoint
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $SetupAccount,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [array]
        $CipherSuitesOrder,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $SPAlternateUrlItem,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [version]
        $StigVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Exception,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [object]
        $OrgSettings,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $SkipRule,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $SkipRuleType,

        [Parameter()]
        [ValidateSet('CAT_I', 'CAT_II', 'CAT_III')]
        [string[]]
        $SkipRuleSeverity
    )

    ##### BEGIN DO NOT MODIFY #####
    $stig = [STIG]::New('Sharepoint', $SharePointVersion, $StigVersion)
    $stig.LoadRules($OrgSettings, $Exception, $SkipRule, $SkipRuleType, $SkipRuleSeverity)
    ##### END DO NOT MODIFY #####

    Import-DscResource -ModuleName SharePointDSC -ModuleVersion 4.2.0
    . "$resourcePath\SharePoint.SPWebAppGeneralSettings.ps1"
    . "$resourcePath\SharePoint.SPAlternateUrl.ps1"

    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 3.2.0
    . "$resourcePath\SharePoint.xSslSettings.ps1" 

    Import-DscResource -ModuleName sChannelDsc -ModuleVersion 1.2.0
    . "$resourcePath\SharePoint.CipherSuites.ps1"

    Import-DscResource -ModuleName PSDscResources -ModuleVersion 2.12.0.0
    . "$resourcePath\windows.Script.skip.ps1"
}
