#region Header
. $PSScriptRoot\.tests.header.ps1
$setDynamicClassFileParams = @{
    ClassModuleFileName = 'PermissionRule.Convert.psm1'
    PowerStigBuildPath  = $script:moduleRoot
    DestinationPath     = (Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\PermissionRule.Convert.ps1')
}
Set-DynamicClassFile @setDynamicClassFileParams
. $setDynamicClassFileParams.DestinationPath
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Path = '%windir%\SYSTEM32\WINEVT\LOGS\Security.evtx'
                AccessControlEntry = @(
                    [pscustomobject]@{
                        Rights = 'FullControl'
                        Inheritance = $null
                        Principal = 'Eventlog'
                        ForcePrincipal = $false
                    }
                    [pscustomobject]@{
                        Rights = 'FullControl'
                        Inheritance = $null
                        Principal = 'SYSTEM'
                        ForcePrincipal = $false
                    }
                    [pscustomobject]@{
                        Rights = 'FullControl'
                        Inheritance = $null
                        Principal = 'Administrators'
                        ForcePrincipal = $false
                    }
                )
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the permissions on the Security event log (Security.evtx).  Standard user accounts or groups must not have access.  The default permissions listed below satisfy this requirement:

            Eventlog - Full Control
            SYSTEM - Full Control
            Administrators - Full Control

            The default location is the "%SystemRoot%\SYSTEM32\WINEVT\LOGS" directory.  They may have been moved to another folder.

            If the permissions for these files are not as restrictive as the ACLs listed, this is a finding.'
            }
            @{
                Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\'
                AccessControlEntry = @(
                    [pscustomobject]@{
                        Rights = "FullControl"
                        Inheritance = "This Key and Subkeys"
                        Principal = "Administrators"
                        ForcePrincipal = $false
                    }
                    [pscustomobject]@{
                        Rights = "ReadKey"
                        Inheritance = "This Key Only"
                        Principal = "Backup Operators"
                        ForcePrincipal = $false
                    }
                    [pscustomobject]@{
                        Rights = "ReadKey"
                        Inheritance = "This Key and Subkeys"
                        Principal = "LOCAL SERVICE"
                        ForcePrincipal = $false
                    }
                )
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Run "Regedit".
                Navigate to the following registry key:
                HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\

                If the key does not exist, this is a finding.

                Right-click on "winreg" and select "Permissions".
                Select "Advanced".

                If the permissions are not as restrictive as the defaults listed below, this is a finding.

                The following are the same for each permission listed:
                Type - Allow
                Inherited from - None

                Columns: Principal - Access - Applies to
                Administrators - Full Control - This key and subkeys
                Backup Operators - Read - This key only
                LOCAL SERVICE - Read - This key and subkeys'
            }
            @{
                # Windows 10 STIG V-63593
                Path = 'HKLM:\SECURITY'
                AccessControlEntry = @(
                    [pscustomobject]@{
                        Rights = 'FullControl'
                        Inheritance = 'This Key and subkeys'
                        Principal = 'SYSTEM'
                        ForcePrincipal = $false
                    }
                )
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the default registry permissions for the keys note below of the HKEY_LOCAL_MACHINE hive.

            If any non-privileged groups such as Everyone, Users or Authenticated Users have greater than Read permission, this is a finding.

            Run "Regedit".
            Right click on the registry areas noted below.
            Select "Permissions..." and the "Advanced" button.

            HKEY_LOCAL_MACHINE\SECURITY
            Type - "Allow" for all
            Inherited from - "None" for all
            Principal - Access - Applies to
            SYSTEM - Full Control - This key and subkeys
            Administrators - Special - This key and subkeys


            Other samples under the noted keys may also be sampled.  There may be some instances where non-privileged groups have greater than Read
            permission.

            If the defaults have not been changed, these are not a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'MultipleRules' {
            # TODO move this to the CommonTests
            $testRuleList = @(
                @{
                    Count = 2
                    CheckContent = 'The default permissions are adequate when the Security Option "Network access: Let everyone permissions apply to anonymous users" is set to "Disabled" (V-3377). If the default ACLs are maintained and the referenced option is set to "Disabled", this is not a finding.

                    Verify the default permissions for the program file directories (Program Files and Program Files (x86)). Nonprivileged groups such as Users or Authenticated Users must not have greater than Read & execute permissions except where noted as defaults. (Individual accounts must not be used to assign permissions.)

                    Viewing in File Explorer:
                    For each folder, view the Properties.
                    Select the "Security" tab, and the "Advanced" button.

                    Default Permissions:
                    \Program Files and \Program Files (x86)
                    Type - "Allow" for all
                    Inherited from - "None" for all

                    Principal - Access - Applies to

                    TrustedInstaller - Full control - This folder and subfolders
                    SYSTEM - Modify - This folder only
                    SYSTEM - Full control - Subfolders and files only
                    Administrators - Modify - This folder only
                    Administrators - Full control - Subfolders and files only
                    Users - Read & execute - This folder, subfolders and files
                    CREATOR OWNER - Full control - Subfolders and files only
                    ALL APPLICATION PACKAGES - Read & execute - This folder, subfolders and files'
                }
            )

            foreach ($testRule in $testRuleList)
            {
                It "Should return $true" {
                    $multipleRule = [PermissionRuleConvert]::HasMultipleRules($testRule.CheckContent)
                    $multipleRule | Should -Be $true
                }
                It "Should return $($testRule.Count) rules" {
                    $multipleRule = [PermissionRuleConvert]::SplitMultipleRules($testRule.CheckContent)
                    $multipleRule.count | Should -Be $testRule.Count
                }
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
