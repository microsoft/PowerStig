#region Header
. $PSScriptRoot\.tests.header.ps1
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
            },
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
            },
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
            },
            @{
                Path = '%windir%\sysvol'
                AccessControlEntry = @(
                    [pscustomobject]@{
                        Rights         = 'ReadAndExecute'
                        Inheritance    = 'This folder subfolders and files'
                        Principal      = 'Authenticated Users'
                        ForcePrincipal = $false
                        Type           = 'Allow'
                    },
                    [pscustomobject]@{
                        Rights         = 'ReadAndExecute'
                        Inheritance    = 'This folder subfolders and files'
                        Principal      = 'Server Operators'
                        ForcePrincipal = $false
                        Type           = 'Allow'
                    },
                    [pscustomobject]@{
                        Rights         = 'AppendData,ChangePermissions,CreateDirectories,CreateFiles,Delete,DeleteSubdirectoriesAndFiles,ExecuteFile,ListDirectory,Modify,Read,ReadAndExecute,ReadAttributes,ReadData,ReadExtendedAttributes,ReadPermissions,Synchronize,TakeOwnership,Traverse,Write,WriteAttributes,WriteData,WriteExtendedAttributes'
                        Inheritance    = 'This folder only'
                        Principal      = 'Administrators'
                        ForcePrincipal = $false
                        Type           = 'Allow'
                    },
                    [pscustomobject]@{
                        Rights         = 'FullControl'
                        Inheritance    = 'Subfolders and files only'
                        Principal      = 'CREATOR OWNER'
                        ForcePrincipal = $false
                        Type           = 'Allow'
                    },
                    [pscustomobject]@{
                        Rights         = 'FullControl'
                        Inheritance    = 'Subfolders and files only'
                        Principal      = 'Administrators'
                        ForcePrincipal = $false
                        Type           = 'Allow'
                    },
                    [pscustomobject]@{
                        Rights         = 'FullControl'
                        Inheritance    = 'This folder subfolders and files'
                        Principal      = 'SYSTEM'
                        ForcePrincipal = $false
                        Type           = 'Allow'
                    }
                )
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = "Verify the permissions on the SYSVOL directory.

                Open a command prompt.
                Run `"net share`".
                Make note of the directory location of the SYSVOL share.

                By default this will be \Windows\SYSVOL\sysvol.  For this requirement, permissions will be verified at the first SYSVOL directory level.

                Open File Explorer.
                Navigate to \Windows\SYSVOL (or the directory noted previously if different).
                Right click the directory and select properties.
                Select the Security tab.
                Click Advanced.

                If any standard user accounts or groups have greater than read &amp; execute permissions, this is a finding. The default permissions noted below meet this requirement.

                Type - Allow
                Principal - Authenticated Users
                Access - Read &amp; execute
                Inherited from - None
                Applies to - This folder, subfolder and files

                Type - Allow
                Principal - Server Operators
                Access - Read &amp; execute
                Inherited from - None
                Applies to - This folder, subfolder and files

                Type - Allow
                Principal - Administrators
                Access - Special
                Inherited from - None
                Applies to - This folder only
                (Access - Special - Basic Permissions: all selected except Full control)

                Type - Allow
                Principal - CREATOR OWNER
                Access - Full control
                Inherited from - None
                Applies to - Subfolders and files only

                Type - Allow
                Principal - Administrators
                Access - Full control
                Inherited from - None
                Applies to - Subfolders and files only

                Type - Allow
                Principal - SYSTEM
                Access - Full control
                Inherited from - None
                Applies to - This folder, subfolders and files

                Alternately, use Icacls.exe to view the permissions of the SYSVOL directory.
                Open a command prompt.
                Run `"icacls c:\Windows\SYSVOL
                The following results should be displayed:

                NT AUTHORITY\Authenticated Users:(RX)
                NT AUTHORITY\Authenticated Users:(OI)(CI)(IO)(GR,GE)
                BUILTIN\Server Operators:(RX)
                BUILTIN\Server Operators:(OI)(CI)(IO)(GR,GE)
                BUILTIN\Administrators:(M,WDAC,WO)
                BUILTIN\Administrators:(OI)(CI)(IO)(F)
                NT AUTHORITY\SYSTEM:(F)
                NT AUTHORITY\SYSTEM:(OI)(CI)(IO)(F)
                BUILTIN\Administrators:(M,WDAC,WO)
                CREATOR OWNER:(OI)(CI)(IO)(F)

                (RX) - Read &amp; execute
                Run `"icacls /help`" to view definitions of other permission codes."
            },
            @{
                Path = '%windir%\NTDS\*.*'
                AccessControlEntry = @(
                    [pscustomobject]@{
                        Rights         = 'FullControl'
                        Inheritance    = ''
                        Principal      = 'NT AUTHORITY\SYSTEM'
                        ForcePrincipal = $false
                    }
                )
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the permissions on the content of the NTDS directory.
                Open the registry editor (regedit).
                Navigate to HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\NTDS\Parameters.
                Note the directory locations in the values for:
                Database log files path
                DSA Database file
                By default they will be \Windows\NTDS. If the locations are different, the following will need to be run for each.
                Open an elevated command prompt (Win+x, Command Prompt (Admin)).
                Navigate to the NTDS directory (\Windows\NTDS by default).
                Run "icacls *.*".
                If the permissions on each file are not at least as restrictive as the following, this is a finding.
                NT AUTHORITY\SYSTEM:(I)(F)
                (I) - permission inherited from parent container
                (F) - full access
                Do not use File Explorer to attempt to view permissions of the NTDS folder. Accessing the folder through File Explorer will change the permissions on the folder.'
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
