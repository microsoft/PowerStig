#region Header
using module .\..\..\..\Module\Convert.PermissionRule\Convert.PermissionRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rulesToTest = @(
            @{
                Path               = '%windir%\SYSTEM32\WINEVT\LOGS\Security.evtx'
                AccessControlEntry = @(
                    [pscustomobject[]]@{
                        Principal   = "Eventlog"
                        Rights      = "FullControl"
                        Inheritance = ""
                    }
                    [pscustomobject[]]@{
                        Principal   = "SYSTEM"
                        Rights      = "FullControl"
                        Inheritance = ""
                    }
                    [pscustomobject[]]@{
                        Principal   = "Administrators"
                        Rights      = "FullControl"
                        Inheritance = ""
                    }
                )
                CheckContent = 'Verify the permissions on the Security event log (Security.evtx).  Standard user accounts or groups must not have access.  The default permissions listed below satisfy this requirement:

            Eventlog - Full Control
            SYSTEM - Full Control
            Administrators - Full Control

            The default location is the "%SystemRoot%\SYSTEM32\WINEVT\LOGS" directory.  They may have been moved to another folder.

            If the permissions for these files are not as restrictive as the ACLs listed, this is a finding.'
            }
            @{
                Path               = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\'
                AccessControlEntry = @(
                    [pscustomobject[]]@{
                        Principal   = "Administrators"
                        Rights      = "FullControl"
                        Inheritance = "This Key and Subkeys"
                    }
                    [pscustomobject[]]@{
                        Principal   = "Backup Operators"
                        Rights      = "Read"
                        Inheritance = "This Key Only"
                    }
                    [pscustomobject[]]@{
                        Principal   = "LOCAL SERVICE"
                        Rights      = "Read"
                        Inheritance = "This Key and Subkeys"
                    }
                )
                CheckContent       = 'Run "Regedit".
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
                Path               = 'HKLM:\SECURITY'
                AccessControlEntry = @{
                    System = @{
                        Rights      = 'FullControl'
                        Inheritance = 'This Key and subkeys'
                        Type        = 'Allow'
                    }
                }
                CheckContent       = 'Verify the default registry permissions for the keys note below of the HKEY_LOCAL_MACHINE hive.

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
        $MultiplePaths = @{
            Paths             = '%ProgramFiles%;%ProgramFiles(x86)'
            CheckContent      = 'The default permissions are adequate when the Security Option "Network access: Let everyone permissions apply to anonymous users" is set to "Disabled" (V-3377). If the default ACLs are maintained and the referenced option is set to "Disabled", this is not a finding.

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
        ALL APPLICATION PACKAGES - Read & execute - This folder, subfolders and files

        Alternately, use Icacls:

        Open a Command prompt (admin).
        Enter icacls followed by the directory:

        icacls "c:\program files"
        icacls "c:\program files (x86)"

        The following results should be displayed as each is entered:

        c:\program files
        NT SERVICE\TrustedInstaller:(F)
        NT SERVICE\TrustedInstaller:(CI)(IO)(F)
        NT AUTHORITY\SYSTEM:(M)
        NT AUTHORITY\SYSTEM:(OI)(CI)(IO)(F)
        BUILTIN\Administrators:(M)
        BUILTIN\Administrators:(OI)(CI)(IO)(F)
        BUILTIN\Users:(RX)
        BUILTIN\Users:(OI)(CI)(IO)(GR,GE)
        CREATOR OWNER:(OI)(CI)(IO)(F)
        APPLICATION PACKAGE AUTHORITY\ALL APPLICATION PACKAGES:(RX)
        APPLICATION PACKAGE AUTHORITY\ALL APPLICATION PACKAGES:(OI)(CI)(IO)(GR,GE)
        Successfully processed 1 files; Failed processing 0 files'
            SplitMultplePaths = @('%ProgramFiles%', '%ProgramFiles(x86)%')
        }
        $rule = [PermissionRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It "Shoud have a BaseType of STIG" {
                    $rule.GetType().BaseType.ToString() | Should Be 'STIG'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('Path', 'AccessControlEntry')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }

            Context 'Class Methods' {

                $classMethods = @('SetPath', 'SetForce', 'SetAccessControlEntry')

                foreach ( $method in $classMethods )
                {
                    It "Should have a method named '$method'" {
                        ( $rule | Get-Member -Name $method ).Name | Should Be $method
                    }
                }

                # If new methods are added this will catch them so test coverage can be added
                It "Should not have more methods than are tested" {
                    $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
                    $memberActual = ( $rule | Get-Member -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }

            Context 'Static Methods' {

                $staticMethods = @('HasMultipleRules', 'SplitMultipleRules')

                foreach ( $method in $staticMethods )
                {
                    It "Should have a method named '$method'" {
                        ( [PermissionRule] | Get-Member -Static -Name $method ).Name | Should Be $method
                    }
                }
                # If new methods are added this will catch them so test coverage can be added
                It "Should not have more static methods than are tested" {
                    $memberPlanned = Get-StigBaseMethods -Static -ChildClassMethodNames $staticMethods
                    $memberActual = ( [PermissionRule] | Get-Member -Static -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-PermissionTargetPath' {

            foreach ( $rule in $rulesToTest )
            {
                It "Should return '$($rule.Path)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    Get-PermissionTargetPath -StigString $checkContent | Should Be $rule.Path
                }
            }
        }

        Describe 'Get-PermissionAccessControlEntry' {

            foreach ( $rule in $rulesToTest )
            {
                It "Should return expected AccessControlEntry object for target '$($rule.Path)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $accessControlEntry = Get-PermissionAccessControlEntry -StigString $checkContent
                    $compare = Compare-Object -ReferenceObject $accessControlEntry -DifferenceObject $rule.AccessControlEntry
                    $compare.Count | Should Be 0
                }
            }
        }

        Describe 'Test-MultiplePermissionRule' {

            It "Should return $true when multple paths found" {
                Test-MultiplePermissionRule -PermissionPath $multiplePaths.Paths | Should be $true
            }
        }

        Describe 'Split-MultiplePermissionRule' {
            $checkContent = Split-TestStrings -CheckContent $multiplePaths.CheckContent
            $paths = Split-MultiplePermissionRule -CheckContent $checkContent

            It "Should return multiple paths" {
                $paths.Count | Should Be 2
            }

            Context "Should contain one path and not the other" {
                foreach ($path in $paths)
                {
                    $matchProgramFiles86 += ($path -split '\n').Trim() | ForEach-Object -Process {$_ -match '^\\Program Files \(x86\)$'}
                    $matchProgramFiles += ($path -split '\n').Trim() | ForEach-Object -Process {$_ -match '^\\Program Files$'}
                }

                It 'Should match Program Files (x86) only' {
                    $result = $matchProgramFiles86 | Where-Object -FilterScript {$_ -eq $true}
                    $result.count | Should Be 1
                }

                It 'Should match Program Files only' {
                    $result = $matchProgramFiles | Where-Object -FilterScript {$_ -eq $true}
                    $result.count | Should Be 1
                }
            }
        }
        #endregion
        #region Function Tests
        Describe "ConvertTo-PermissionRule" {
            $checkContent = @'
The default permissions are adequate when the Security Option "Network access: Let everyone permissions apply to anonymous users" is set to "Disabled" (V-3377).  If the default ACLs are maintained and the referenced option is set to "Disabled", this is not a finding.

Verify the default permissions for the system drive's root directory (usually C:\).  Nonprivileged groups such as Users or Authenticated Users must not have greater than Read &amp; execute permissions except where noted as defaults.  (Individual accounts must not be used to assign permissions.)

Viewing in File Explorer:
View the Properties of system drive root directory.
Select the "Security" tab, and the "Advanced" button.

C:\
Type - "Allow" for all
Inherited from - "None" for all

Principal - Access - Applies to

SYSTEM - Full control - This folder, subfolders and files
Administrators - Full control - This folder, subfolders and files
Users - Read &amp; execute - This folder, subfolders and files
Users - Create folders / append data - This folder and subfolders
Users - Create files / write data - Subfolders only
CREATOR OWNER - Full Control - Subfolders and files only

Alternately, use Icacls:

Open a Command prompt (admin).
Enter icacls followed by the directory:

icacls c:\

The following results should be displayed:

c:\
NT AUTHORITY\SYSTEM:(OI)(CI)(F)
BUILTIN\Administrators:(OI)(CI)(F)
BUILTIN\Users:(OI)(CI)(RX)
BUILTIN\Users:(CI)(AD)
BUILTIN\Users:(CI)(IO)(WD)
CREATOR OWNER:(OI)(CI)(IO)(F)
Successfully processed 1 files; Failed processing 0 files
'@
            $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
            $rule = ConvertTo-PermissionRule -StigRule $stigRule

            It "Should return an PermissionRule object" {
                $rule.GetType() | Should Be 'PermissionRule'
            }
        }
        Describe "Private Permission Rule" {

            [string] $functionName = 'Get-PermissionTargetPath'
            Context $functionName {

                # get path that pertain to C:\ tests
                $stringsToTestcDrive = @("system drive's root directory", "system drive's root directory ", " system drive's root directory")
                $testTargetPathcDrive = '%SystemDrive%\'

                foreach ( $string in $stringsToTestcDrive )
                {
                    It "Should return $testTargetPathcDrive from $string" {
                        Get-PermissionTargetPath -StigString $string | Should Be $testTargetPathcDrive
                    }
                }

                # get path for permissions that pertain to eventvwr.exe tests
                $stringsToTesteventvwr = @('eventvwr.exe', ' eventvwr.exe', 'eventvwr.exe ',
                    ' The event viewer is eventvwr.exe '
                )
                $testTargetPathEventvwr = '%windir%\SYSTEM32\eventvwr.exe'
                foreach ( $string in $stringsToTestEventvwr )
                {
                    It "Should return $testTargetPathEventvwr from $string" {
                        Get-PermissionTargetPath -StigString $string | Should Be $testTargetPathEventvwr
                    }
                }

                # get path for permissions that pertain to event logs tests
                $stringsToTestEventLogDirectory = @( '%SystemRoot%\SYSTEM32\WINEVT\LOGS ', '  %SystemRoot%\SYSTEM32\WINEVT\LOGS ',
                    '  %SystemRoot%\SYSTEM32\WINEVT\LOGS', '%SystemRoot%\SYSTEM32\WINEVT\LOGS  ',
                    'The eventlog directory is %SystemRoot%\SYSTEM32\WINEVT\LOGS period. ')
                $eventLogFiles = @('Security.evtx', 'Application.evtx', 'System.evtx')
                $testTargetPathEventLogDirectory = '%windir%\SYSTEM32\WINEVT\LOGS'

                foreach ( $string in $stringsToTestEventLogDirectory )
                {
                    foreach ( $eventLogFile in $eventLogFiles )
                    {
                        $testString = $string + "(" + $eventLogFile + ")"
                        $testTargetPathEventLogDirectoryResult = "$($testTargetPathEventLogDirectory.trim())\$($eventLogFile.Trim())"

                        It "Should return $testTargetPathEventLogDirectoryResult from $string" {

                            Get-PermissionTargetPath -StigString $testString | Should Be $testTargetPathEventLogDirectoryResult
                        }
                    }
                }
            }

            [string] $functionName = 'ConvertTo-AccessControlEntry'
            Context $functionName {

                # Test scenario for same FileSystemRights for multiple Principals
                $multiplePrincipalString = 'Administrators, SYSTEM, Users, ALL APPLICATION PACKAGES - Read & Execute'

                It "Should return a principal count of 4" {
                    $result = ConvertTo-AccessControlEntry -StigString $multiplePrincipalString
                    $result.Principal.count | Should Be 4
                }

                It "Should have matching Values" {
                    $result = ConvertTo-AccessControlEntry -StigString $multiplePrincipalString

                    foreach ( $entry in $result )
                    {
                        $i = 0
                        while ( $i -lt $result.count)
                        {
                            $entry.'FileSystemRights' | Should Be $result[$i].'FileSystemRights'
                            $i++

                        }
                    }
                }

                # Test scenario for different FileSystemRights for each principal
                $differentPermissions = "
                Users - Read & execute - This folder, subfolders and files
                Users - Create folders / append data - This folder and subfolders
                "
                It "Should assign different permissions" {
                    $result = ConvertTo-AccessControlEntry -StigString $differentPermissions
                    {$result[0].FileSystemRights -ne $result[1].FileSystemRights} | Should Be $true
                }

                # Test scenario for same Inheritance for multiple Principals
                It "Should have matching Inheritance values" {
                    $inheritanceValue = "This folder and subfolders"
                    $result = ConvertTo-AccessControlEntry -StigString $multiplePrincipalString -InheritenceInput $inheritanceValue
                    foreach ( $entry in $result )
                    {
                        $entry.Inheritance | Should Be $script:inheritenceConstant.$inheritanceValue
                    }
                }
            }
        }
        #endregion
        #region Data Tests
        Describe "fileRightsConstant Data Section" {

            [string] $dataSectionName = 'fileRightsConstant'

            It "Should have a data section called $dataSectionName" {
                ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
            }
        }

        Describe "registryRightsConstant Data Section" {

            [string] $dataSectionName = 'registryRightsConstant'

            It "Should have a data section called $dataSectionName" {
                ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
            }

            <#
            TO DO - Add rules
            #>
        }

        Describe "activeDirectoryRightsConstant Data Section" {

            [string] $dataSectionName = 'activeDirectoryRightsConstant'

            It "Should have a data section called $dataSectionName" {
                ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
            }

            <#
            TO DO - Add rules
            #>
        }

        Describe "inheritenceConstant Data Section" {

            [string] $dataSectionName = 'inheritenceConstant'

            It "Should have a data section called $dataSectionName" {
                ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
            }

            <#
            TO DO - Add rules
            #>
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
