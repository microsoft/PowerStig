#region  Header
using module ..\..\..\..\src\public\class\PermissionRuleClass.psm1
. $PSScriptRoot\..\..\..\helper.ps1
$ruleClassName = ($MyInvocation.MyCommand.Name -Split '\.')[0]
#endregion Header

#region Test Setup
$rule = [PermissionRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$permissionRulesToTest = @(
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
        CheckContent       = 'Verify the permissions on the Security event log (Security.evtx).  Standard user accounts or groups must not have access.  The default permissions listed below satisfy this requirement:

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
        Path = 'HKLM:\SECURITY'
        AccessControlEntry = @{
                System      = @{
                Rights      = 'FullControl'
                Inheritance = 'This Key and subkeys'
                Type        = 'Allow'
            }
        }
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
$MultiplePaths = @{
    Paths = '%ProgramFiles%;%ProgramFiles(x86)'
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

#endregion Test Setup

#region Class Tests
Describe "$ruleClassName Child Class" {
    
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
#endregion Class Tests

#region Method function Tests
Describe 'Get-PermissionTargetPath' {

    foreach ( $permission in $permissionRulesToTest )
    {
        It "Should return '$($permission.Path)'" {
            $Path = Get-PermissionTargetPath -StigString ($permission.CheckContent -split '\n').Trim()
            $Path | Should Be $Permission.Path
        } 
    }
}

Describe 'Get-PermissionAccessControlEntry' {
    
    foreach ( $permission in $permissionRulesToTest )
    {
        It "Should return expected AccessControlEntry object for target '$($permission.Path)'" {
            $accessControlEntry = Get-PermissionAccessControlEntry -StigString ($permission.CheckContent -split '\n')
            $compare = Compare-Object -ReferenceObject $accessControlEntry -DifferenceObject $permission.AccessControlEntry
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
    $paths = Split-MultiplePermissionRule -CheckContent ($multiplePaths.CheckContent -split '\n').Trim()

    It "Should return multiple paths" {
        $paths.Count | Should Be 2
    }

    Context "Should contain one path and not the other" {
        foreach ($path in $paths)
        {
            $matchProgramFiles86 += ($path -split '\n').Trim() | ForEach-Object -Process {$_ -match '^\\Program Files \(x86\)$'}
            $matchProgramFiles   += ($path -split '\n').Trim() | ForEach-Object -Process {$_ -match '^\\Program Files$'}
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
#endregion Method function Tests
