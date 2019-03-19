# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\PermissionRule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into a permission object
    .DESCRIPTION
        The PermissionRule class is used to extract the permission settings
        from the check-content of the xccdf. Once a STIG rule is identified a
        permission rule, it is passed to the PermissionRule class for parsing
        and validation.
#>
Class PermissionRuleConvert : PermissionRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    PermissionRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts an xccdf stig rule element into a Permission Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    PermissionRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        if ($this.IsDuplicateRule($global:stigSettings))
        {
            $this.SetDuplicateOf($this.id)
        }
        $this.SetPath()
        $this.SetDscResource()
        $this.SetForce()
        $this.SetAccessControlEntry()
    }

    # Methods

    <#
        .SYNOPSIS
            Extracts the object path from the check-content and sets the value
        .DESCRIPTION
            Gets the object path from the xccdf content and sets the value.
            If the object path that is returned is not valid, the parser
            status is set to fail
    #>
    [void] SetPath ()
    {
        $thisPath = Get-PermissionTargetPath -StigString $this.SplitCheckContent

        if (-not $this.SetStatus($thisPath))
        {
            $this.set_Path($thisPath)
        }
    }

    <#
        .SYNOPSIS
            Sets the force flag
        .DESCRIPTION
            For now we're setting a default value. Later there could be
            additional logic here
    #>
    [void] SetForce ()
    {
        $this.set_Force($true)
    }

    <#
        .SYNOPSIS
            Extracts the ACE from the check-content and sets the value
        .DESCRIPTION
            Gets the ACE from the xccdf content and sets the value. If the ACE
            that is returned is not valid, the parser status is set to fail
    #>
    [void] SetAccessControlEntry ()
    {
        $thisAccessControlEntry = Get-PermissionAccessControlEntry -StigString $this.SplitCheckContent

        if (-not $this.SetStatus($thisAccessControlEntry))
        {
            foreach ($principal in $thisAccessControlEntry.Principal)
            {
                $this.SetStatus($principal)
            }

            foreach ($rights in $thisAccessControlEntry.Rights)
            {
                if ($rights -eq 'blank')
                {
                    $this.SetStatus("", $true)
                    continue
                }
                $this.SetStatus($rights)
            }

            $this.set_AccessControlEntry($thisAccessControlEntry)
        }
    }

    hidden [void] SetDscResource ()
    {
        if($null -eq $this.DuplicateOf)
        {
            if ($this.Path)
            {
                switch ($this.Path)
                {
                    {$PSItem -match '{domain}'}
                    {
                        $this.DscResource = "ActiveDirectoryAuditRuleEntry"
                    }
                    {$PSItem -match 'HKLM:\\'}
                    {
                        $this.DscResource = 'RegistryAccessEntry'
                    }
                    {$PSItem -match '(%windir%)|(ProgramFiles)|(%SystemDrive%)|(%ALLUSERSPROFILE%)'}
                    {
                        $this.DscResource = 'NTFSAccessEntry'
                    }
                }
            }
        }
        else
        {
            $this.DscResource = 'None'
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match 'permission(s|)' -and
            $CheckContent -NotMatch 'Forward\sLookup\sZones|Devices\sand\sPrinters|Shared\sFolders' -and
            $CheckContent -NotMatch 'Verify(ing)? the ((permissions .* ((G|g)roup (P|p)olicy|OU|ou))|auditing .* ((G|g)roup (P|p)olicy))' -and
            $CheckContent -NotMatch 'Windows Registry Editor' -and
            $CheckContent -NotMatch '(ID|id)s? .* (A|a)uditors?,? (SA|sa)s?,? .* (W|w)eb (A|a)dministrators? .* access to log files?' -and
            $CheckContent -NotMatch '\n*\.NET Trust Level' -and
            $CheckContent -NotMatch 'IIS 8\.5 web' -and
            $CheckContent -cNotmatch 'SELECT' -and
            $CheckContent -NotMatch 'SQL Server' -and
            $CheckContent -NotMatch 'user\srights\sand\spermissions' -and
            $CheckContent -NotMatch 'Query the SA' -and
            $CheckContent -NotMatch "caspol\.exe" -and
            $CheckContent -NotMatch "Select the Group Policy Object item in the left pane" -and
            $CheckContent -NotMatch "Deny log on through Remote Desktop Services" -and
            $CheckContent -NotMatch "Interview the IAM" -and
            $CheckContent -NotMatch "InetMgr\.exe" -and
            $CheckContent -NotMatch "Register the required DLL module by typing the following at a command line ""regsvr32 schmmgmt.dll""." -and
            $CheckContent -NotMatch 'If any private assets' -and
            $CheckContent -NotMatch "roles.sql"
        )
        {
            return $true
        }
        return $false
    }

    <#
        .SYNOPSIS
            Tests if a rules contains more than one check
        .DESCRIPTION
            Gets the path defined in the rule from the xccdf content and then
            checks for the existance of multuple entries.
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    <#{TODO}#> # HasMultipleRules is implemented inconsistently.
    static [bool] HasMultipleRules ([string] $CheckContent)
    {
        $permissionPaths = Get-PermissionTargetPath -StigString ([PermissionRule]::SplitCheckContent($CheckContent))
        return (Test-MultiplePermissionRule -PermissionPath $permissionPaths)
    }

    <#
        .SYNOPSIS
            Splits mutiple paths from a singel rule into multiple rules
        .DESCRIPTION
            Once a rule has been found to have multiple checks, the rule needs
            to be split. This method splits a permission check into multiple rules.
            Each split rule id is appended with a dot and letter to keep reporting
            per the ID consistent. An example would be is V-1000 contained 2
            checks, then SplitMultipleRules would return 2 objects with rule ids
            V-1000.a and V-1000.b
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    static [string[]] SplitMultipleRules ([string] $CheckContent)
    {
        return (Split-MultiplePermissionRule -CheckContent ([PermissionRule]::SplitCheckContent($CheckContent)))
    }

    #endregion
}
