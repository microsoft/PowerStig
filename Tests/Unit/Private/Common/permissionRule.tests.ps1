#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.psm1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module $modulePath -Force
#endregion
#region Test Setup
$checkContent = @'
'The default permissions are adequate when the Security Option "Network access: Let everyone permissions apply to anonymous users" is set to "Disabled" (V-3377).  If the default ACLs are maintained and the referenced option is set to "Disabled", this is not a finding.

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
Successfully processed 1 files; Failed processing 0 files'
'@
#endregion
#region Tests
Describe "ConvertTo-PermissionRule" {
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
        $stringsToTestcDrive  = @("system drive's root directory","system drive's root directory "," system drive's root directory")
        $testTargetPathcDrive = '%SystemDrive%\'

        foreach ( $string in $stringsToTestcDrive )
        {
            It "Should return $testTargetPathcDrive from $string" {
                Get-PermissionTargetPath -StigString $string | Should Be $testTargetPathcDrive
            }
        }

        # get path for permissions that pertain to eventvwr.exe tests
        $stringsToTesteventvwr = @('eventvwr.exe',' eventvwr.exe','eventvwr.exe ',
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
            '  %SystemRoot%\SYSTEM32\WINEVT\LOGS','%SystemRoot%\SYSTEM32\WINEVT\LOGS  ',
            'The eventlog directory is %SystemRoot%\SYSTEM32\WINEVT\LOGS period. ')
        $eventLogFiles = @('Security.evtx','Application.evtx','System.evtx')
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

        # test scenario for same FileSystemRights for multiple Principals
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

        # test scenario for different FileSystemRights for each principal
		$differentPermissions = "
        Users - Read & execute - This folder, subfolders and files
        Users - Create folders / append data - This folder and subfolders
        "
        It "Should assign different permissions" {

            $result = ConvertTo-AccessControlEntry -StigString $differentPermissions

            {$result[0].FileSystemRights -ne $result[1].FileSystemRights} | Should Be $true
        }

        # test scenario for same Inheritance for multiple Principals
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
