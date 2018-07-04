#region Convert Class Header V1
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\Common.Enum.psm1
using module .\..\Data\Convert.Data.psm1
# Additional required modules
using module .\..\..\Private\Class\Convert.Common.HardCodedValue.psm1
using module .\..\..\Private\Class\Convert.Common.RangeConversion.psm1
using assembly System.Web
#endregion
#region Class Definition
Class STIG : ICloneable
{
    # The STIG ID
    [String] $id

    # Title string from STIG
    [String] $title

    # Severity data from STIG
    [severity] $severity

    # Module processing status of the raw string
    [status] $conversionstatus

    # The raw string from the check-content element of the STIG item
    [String] $rawString

    # The raw check string split into multiple lines for pattern matching
    hidden [string[]] $SplitCheckContent

    # A flag to determine if a value is supposed to be empty or not.
    # Some items should be empty, but there needs to be a way to validate that empty is on purpose.
    [Boolean] $IsNullOrEmpty

    # A flag to determine if a local organizational setting is required.
    [Boolean] $OrganizationValueRequired

    # A string that can be invoked to test the chosen organizational value.
    [String] $OrganizationValueTestString

    # Defines the DSC resource used to configure the rule
    [String] $dscresource

    # Constructors
    STIG ()
    {
    }

    # Methods
    hidden [void] InvokeClass ( [xml.xmlelement] $StigRule )
    {
        $this.Id = $StigRule.id
        $this.Severity = $StigRule.rule.severity
        $this.Title = $StigRule.title

        # Since the string comes from XML, we have to assume that it is encoded for html.
        # This will decode it back into the normal string characters we are looking for.
        if ( Test-HtmlEncoding -CheckString  $StigRule.rule.Check.('check-content') )
        {
            $this.RawString = ( ConvertFrom-HtmlEncoding -CheckString $StigRule.rule.Check.('check-content') )
        }
        else
        {
            $this.RawString = $StigRule.rule.Check.('check-content')
        }

        <#
            This hidden property is used by all of the methods and passed to subfunctions instead of
            splitting the sting in every function. THe Select-String removes any blank lines, so
            that the Mandatory parameter validataion does not fail and to prevent the need for a
            work around by allowing empty strings in mandaotry parmaeters.
        #>
        $this.SplitCheckContent = [STIG]::SplitCheckContent( $this.rawString )

        # Default Flags
        $this.IsNullOrEmpty = $false
        $this.OrganizationValueRequired = $false
    }

    [Object] Clone ()
    {
        return $this.MemberwiseClone()
    }

    [Boolean] IsDuplicateRule ( [object] $ReferenceObject )
    {
        return Test-DuplicateRule -ReferenceObject $ReferenceObject -DifferenceObject $this
    }

    [void] SetDuplicateTitle ()
    {
        $this.title = $this.title + ' Duplicate'
    }

    # Fail a rule conversion if a propety is null or empty
    [Boolean] SetStatus ( [String] $Value )
    {
        if ( [String]::IsNullOrEmpty( $Value ) )
        {
            $this.conversionstatus = [status]::fail
            return $true
        }
        else
        {
            return $false
        }
    }

    # Fail a rule conversion if a propety is null or empty and not specifically allowed to be
    [Boolean] SetStatus ( [String] $Value, [Boolean] $AllowNullOrEmpty )
    {
        if ( [String]::IsNullOrEmpty( $Value ) -and -not $AllowNullOrEmpty )
        {
            $this.conversionstatus = [status]::fail
            return $true
        }
        else
        {
            return $false
        }
    }

    [void] SetIsNullOrEmpty ()
    {
        $this.IsNullOrEmpty = $true
    }

    [void] SetOrganizationValueRequired ()
    {
        $this.OrganizationValueRequired = $true
    }

    [String] GetOrganizationValueTestString ( [String] $testString )
    {
        return Get-OrganizationValueTestString -String $testString
    }

    [hashtable] ConvertToHashTable ()
    {
        return ConvertTo-HashTable -InputObject $this
    }

    [void] SetStigRuleResource ()
    {
        $thisDscResource = Get-StigRuleResource -RuleType $this.GetType().ToString()

        if ( -not $this.SetStatus( $thisDscResource ) )
        {
            $this.set_dscresource( $thisDscResource )
        }
    }

    static [string[]] SplitCheckContent ( [String] $CheckContent )
    {
        return (
            $CheckContent -split '\n' |
                Select-String -Pattern "\w" |
                ForEach-Object { $PSitem.ToString().Trim() }
        )
    }

    static [string[]] GetFixText ( [xml.xmlelement] $StigRule )
    {
        $fullFix = $StigRule.Rule.fixtext.'#text'

        $return = $fullFix -split '\n' |
                  Select-String -Pattern "\w" |
                  ForEach-Object { $PSitem.ToString().Trim() }

        return $return
    }

    static [RuleType[]] GetRuleTypeMatchList ( [String] $CheckContent )
    {
        return Get-RuleTypeMatchList -CheckContent $CheckContent
    }

    [Boolean] IsExistingRule ( [object] $RuleCollection )
    {
        return Test-ExistingRule -RuleCollection $RuleCollection $this
    }
    #region     #######################   Hard coded Methods    ####################################
    [Boolean] IsHardCoded ()
    {
        return Test-ValueDataIsHardCoded -StigId $this.id
    }

    [String] GetHardCodedString ()
    {
        return Get-HardCodedString -StigId $this.id
    }

    [Boolean] IsHardCodedOrganizationValueTestString ()
    {
        return Test-IsHardCodedOrganizationValueTestString -StigId $this.id
    }

    [String] GetHardCodedOrganizationValueTestString ()
    {
        return Get-HardCodedOrganizationValueTestString -StigId $this.id
    }
    #endregion
}
#endregion
#region Method Functions
<#
    .SYNOPSIS
        Looks at the check-content data and returns the rule type that is should be converted to.

    .PARAMETER CheckContent
        The check-content xml element from the stig rule

    .NOTES
        General notes
#>
function Get-RuleTypeMatchList
{
    [CmdletBinding()]
    [OutputType([RuleType[]])]
    Param
    (
        [parameter(Mandatory = $true)]
        [String]
        $CheckContent
    )

    [System.Collections.ArrayList] $ruleTypeList = @()
    $parsed = $false
    switch ( $CheckContent )
    {
        {
            $PSItem -Match 'gpedit\.msc' -and $PSItem -match 'Account Policies'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::AccountPolicyRule )
            $parsed = $true
        }
        {
            $PSItem -Match "\bAuditpol\b" -and $PSItem -NotMatch "resourceSACL"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::AuditPolicyRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'dnsmgmt\.msc' -and
            $PSItem -NotMatch 'Forward Lookup Zones' -and
            $PSItem -Notmatch 'Logs\\Microsoft' -and
            $PSItem -NotMatch 'Verify the \"root hints\"'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::DnsServerSettingRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'dnsmgmt\.msc' -and
            $PSItem -Match 'Verify the \"root hints\"'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::DnsServerRootHintRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'Logging' -and
            $PSItem -Match 'IIS 8\.5' -and
            $PSItem -NotMatch 'review source IP' -and
            $PSItem -NotMatch 'verify only authorized groups' -and
            $PSItem -NotMatch 'consult with the System Administrator to review' -and
            $PSItem -Notmatch 'If an account associated with roles other than auditors'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::IisLoggingRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'MIME Types' -and
            $PSItem -Match 'IIS 8\.5'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::MimeTypeRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'permission(s|)' -and
            $PSItem -NotMatch 'Forward\sLookup\sZones|Devices\sand\sPrinters|Shared\sFolders' -and
            $PSItem -NotMatch 'Verify(ing)? the ((permissions .* ((G|g)roup (P|p)olicy|OU|ou))|auditing .* ((G|g)roup (P|p)olicy))' -and
            $PSItem -NotMatch 'Windows Registry Editor' -and
            $PSItem -NotMatch '(ID|id)s? .* (A|a)uditors?,? (SA|sa)s?,? .* (W|w)eb (A|a)dministrators? .* access to log files?' -and
            $PSItem -NotMatch '\n*\.NET Trust Level' -and
            $PSItem -NotMatch 'IIS 8\.5 web' -and
            $PSItem -cNotmatch 'SELECT' -and
            $PSItem -NotMatch 'SQL Server' -and
            $PSItem -NotMatch 'user\srights\sand\spermissions' -and
            $PSItem -NotMatch 'Query the SA' -and
            $PSItem -NotMatch "caspol\.exe" -and
            $PSItem -NotMatch "Select the Group Policy object in the left pane" -and
            $PSItem -NotMatch "Deny log on through Remote Desktop Services" -and
            $PSItem -NotMatch "Interview the IAM" -and
            $PSItem -NotMatch "InetMgr\.exe"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::PermissionRule )
            $parsed = $true
        }
        {
            (
                $PSItem -Match "HKEY_LOCAL_MACHINE|HKEY_CURRENT_USER" -and
                $PSItem -NotMatch "Permission(s|)" -and
                $PSItem -NotMatch "SupportedEncryptionTypes" -and
                $PSItem -NotMatch "Sql Server"
            ) -or
            (
                $PSItem -Match "Windows Registry Editor" -and
                $PSItem -Match "HKLM|HKCU"
            ) -or
            (
                $PSItem -match "HKLM|HKCU" -and
                $PSItem -match "REG_DWORD"
            )
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::RegistryRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'gpedit\.msc' -and
            $PSItem -match 'Security Options'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::SecurityOptionRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'services\.msc' -and
            $PSItem -NotMatch 'Required Services' -and
            $PSItem -NotMatch 'presence of applications' -and
            $PSItem -NotMatch 'is not installed by default' -and
            $PSItem -NotMatch 'Sql Server'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::ServiceRule )
            $parsed = $true
        }
        {
            $PSItem -Match "SELECT" -and
            $PSItem -Match 'existence.*publicly available.*(").*(")\s*(D|d)atabase' -or
            $PSItem -Match "(DISTINCT|(D|d)istinct)\s+traceid" -or
            $PSItem -Match "direct access.*server-level" -and
            $PSItem -NotMatch "SHUTDOWN_ON_ERROR" -and
            $PSItem -NotMatch "'Alter any availability group' permission"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::SqlScriptQueryRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'gpedit\.msc' -and
            $PSItem -Match 'User Rights Assignment' -and
            $PSItem -NotMatch 'unresolved SIDs' -and
            $PSItem -NotMatch 'SQL Server'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::UserRightRule )
            $parsed = $true
        }
        {
            $PSItem -cMatch 'IIS' -and
            $PSItem -Match 'Application Pools' -and
            $PSItem -NotMatch 'recycl' -and
            $PSItem -NotMatch 'review the "Applications"'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WebAppPoolRule )
            $parsed = $true
        }
        {
            $PSItem -Match '\.NET Trust Level' -or
            (
                $PSItem -Match 'IIS 8\.5 web' -and
                $PSItem -NotMatch 'document'
            ) -and
            (
                $PSItem -NotMatch 'alternateHostName' -and
                $PSItem -NotMatch 'Application Pools' -and
                $PSItem -NotMatch 'bindings' -and
                $PSItem -NotMatch 'DoD PKI Root CA' -and
                $PSItem -NotMatch 'IUSR account' -and
                $PSItem -NotMatch 'Logging' -and
                $PSItem -NotMatch 'MIME Types' -and
                $PSItem -NotMatch 'Physical Path' -and
                $PSItem -NotMatch 'script extensions' -and
                $PSItem -NotMatch 'recycl' -and
                $PSItem -NotMatch 'WebDAV' -and
                $PSItem -NotMatch 'Review the local users' -and
                $PSItem -NotMatch 'System Administrator' -and
                $PSItem -NotMatch 'are not restrictive enough to prevent connections from nonsecure zones' -and
                $PSItem -NotMatch 'verify the certificate path is to a DoD root CA' -and
                $PSItem -NotMatch 'HKLM' -and
                $PSItem -NotMatch 'Authorization Rules' -and
                $PSItem -NotMatch 'regedit <enter>'
            )
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WebConfigurationPropertyRule )
            $parsed = $true
        }
        {
            $PSItem -Match '(Get-Windows(Optional)?Feature|is not installed by default)' -or
            $PSItem -Match 'WebDAV Authoring Rules' -and
            $PSItem -NotMatch 'HKEY_LOCAL_MACHINE'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WindowsFeatureRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'Logs\\Microsoft' -and
            $PSItem -Match 'eventvwr\.msc'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WinEventLogRule )
            $parsed = $true
        }
        {
            $PSItem -Match "Disk Management" -or
            $PSItem -Match "Service Pack"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WmiRule )
            $parsed = $true
        }
        {
            $PSItem -Match "Get-ProcessMitigation"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::ProcessMitigationRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'Navigate to System Tools >> Local Users and Groups >> Groups\.' -and
            $PSItem -NotMatch 'Backup Operators|Hyper-V Administrators'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::GroupRule )
            $parsed = $true
        }
        <#
            Break out of switch statement once a rule has been parsed before it tries to convert to a
            document or manual rule.
        #>
        {
            $parsed -eq $true
        }
        {
            break
        }
        <#
            Some rules have a documentation requirement only for exceptions, so the DocumentRule
            needs to be at th end of the swtich as a catch all for documentation rules.
        #>
        {
            $PSItem -Match "Document(ation)?" -and
            $PSItem -NotMatch "resourceSACL|Disk Management" -and
            $PSItem -NotMatch "Caspol\.exe" -and
            $PSItem -NotMatch "Examine the \.NET CLR configuration files" -and
            $PSItem -NotMatch "\*\.exe\.config"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::DocumentRule )
        }
        default
        {
            [void] $ruleTypeList.Add( [RuleType]::ManualRule )
        }
    }
    return $ruleTypeList
}

<#
    .SYNOPSIS
        Used to determine the DSC Resource to handle this specific rule

    .PARAMETER StigRule
        The converted rule class based object
#>
function Get-StigRuleResource
{
    param
    (
        [parameter(Mandatory = $true)]
        [RuleType]
        $RuleType
    )

    switch ( $RuleType )
    {
        'PermissionRule'
        {
            $Path = $this.Path
            if ( $Path )
            {
                return Get-PermissionRuleDscResource -Path $Path
            }
        }
        'IISLoggingRUle'
        {
            return Get-IISLoggingRuleDscResource -StigTitle $global:stigTitle
        }
        'WindowsFeature'
        {
            return 'WindowsOptionalFeature'
        }
        default
        {
            return $DscResource.($RuleType.ToString())
        }
    }
}

<#
    .SYNOPSIS
        Returns the name of the DSC resource used to handle the specific rule

    .PARAMETER Path
        Stig Title for the DSC Resource

    .EXAMPLE
        Get-IISLoggingRuleDscResource -StigTitle "IIS 8.5 Server Security Technical Implementation Guide"
#>
function Get-IISLoggingRuleDscResource {
    param
    (
        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String]
        $StigTitle
    )

    if ($StigTitle -match "Server") {
        return "xIISLogging"
    }

    return "XWebsite"
}

<#
    .SYNOPSIS
        Returns the name of the DSC resource used to handle the specific rule

    .PARAMETER Path
        Path value for the permission rule

    .EXAMPLE
    Get-PermissionRuleDscResource -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\"
#>
function Get-PermissionRuleDscResource
{
    param
    (
        [parameter(Mandatory = $true)]
        [String]
        $Path
    )

    switch ($Path)
    {
        {$PSItem -match '{domain}'}
        {
            return "ActiveDirectoryAuditRuleEntry"
        }
        {$PSItem -match 'HKLM:\\'}
        {
            return 'RegistryAccessEntry'
        }
        {$PSItem -match '(%windir%)|(ProgramFiles)|(%SystemDrive%)|(%ALLUSERSPROFILE%)'}
        {
            return 'NTFSAccessEntry'
        }
    }
}

<#
    .SYNOPSIS
        Checks for Html encoded char

    .PARAMETER CheckString
        The string to convert.
#>
function Test-HtmlEncoding
{
    [outputtype([Boolean])]
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $CheckString
    )

    if ( $CheckString -match '&\w+;' )
    {
        return $true
    }
    else
    {
        return $false
    }
}

<#
    .SYNOPSIS
        Converts Html encoded strings back in the ascii char

    .PARAMETER CheckString
        The string to convert.
#>
function ConvertFrom-HtmlEncoding
{
    [outputtype([String])]
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $CheckString
    )

    return [System.Web.HttpUtility]::HtmlDecode( $CheckString )
}

<#
    .SYNOPSIS
        Tests the results of ConvertTo-*Rule functions for duplicates.  The DNS STIG has multiple duplicates but we only
        need to account for them once.  If a duplicate is detected we will convert that rule to a document rule.

    .PARAMETER ReffernceObject
        The list of Stigs objects to compare to.

    .PARAMETER DifferenceObject
        The newly created object to verify is not a duplicate.

    .NOTES
        General notes
#>
function Test-DuplicateRule
{
    [CmdletBinding()]
    [OutputType( [Boolean] )]
    param
    (
        [parameter( Mandatory = $true )]
        [AllowNull()]
        [object]
        $ReferenceObject,

        [parameter( Mandatory = $true )]
        [object]
        $DifferenceObject
    )

    $ruleType = $DifferenceObject.GetType().Name
    $baseStig = [Stig]::New()

    $referenceProperties = ( $baseStig | Get-Member -MemberType Property ).Name
    $differenceProperties = ( $DifferenceObject | Get-Member -MemberType Property ).Name

    $propertyList = (Compare-Object -ReferenceObject $referenceProperties -DifferenceObject $differenceProperties).InputObject
    $referenceRules = $ReferenceObject | Where-Object { $( $PsItem.GetType().Name ) -eq $ruletype }

    foreach ( $rule in $referenceRules )
    {
        $results = @()

        foreach ($propertyName in $PropertyList)
        {
            $results += $rule.$propertyName -eq $DifferenceObject.$propertyName
        }

        if ( $results -notcontains $false )
        {
            Write-Verbose "$($rule.id) is a duplicate"
            return $true
        }
    }
    # if the code made it this far a duplicate does not exist and we return $false
    return $false
}

<#
    .SYNOPSIS
        Looks in $Global:STIGSettings for existing rules

    .NOTES
        Some rules in the STIG enforce multiple settings. This funciton will test for
        this scenario to so we can act upon it later.
#>
function Test-ExistingRule
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter()]
        [object]
        $RuleCollection,

        [Parameter()]
        [object]
        $NewRule
    )

    $IdExist = $RuleCollection | Where-Object {$_.Id -eq $NewRule.Id}

    return $IdExist.id -eq $NewRule.id
}
#endregion
