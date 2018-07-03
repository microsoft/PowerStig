<#
    These unit tests are heavily mocked to verify the presorting functionality is working properly 
    as new STIG parsers are added to the project. The sample xml below represents the xccdf schema. 
    
    Since everything else is ignored by the parsers, the title element is all that we really need 
    the change for individual tests. That is done through PowerShell composite formatting. The 
    $title variable is injected into the sample xccdf and stored in a Pester TestDrive.

    You will see the individual function defined here as well. The project is highly segmented to 
    help logically identify where code is stored. That creates a small challenge for unit testing 
    because the functions we want to mock are not loaded into the current test session. To eliminate 
    any need to dot source all the files in all of the tests, we can simply redefine the function 
    here as a stub, so that Pester can mock it and we can verify code flow.
#>

# Build the path to the system under test
[string] $sut = $MyInvocation.MyCommand.Path -replace '\\tests\\','\src\' `
                                             -replace '\.tests','' `
                                             -replace '\\unit\\','\'
# load the system under test
. $sut
# Import the base benchmark xml string data.
$BaseFileContent = Get-Content -Path "$PSScriptRoot\..\..\..\data\sampleXccdf.xml.txt" -Encoding UTF8

$dcGroupCheck = @"
This applies to domain controllers. A separate version applies to other systems.

Review the Administrators group. Only the appropriate administrator groups or accounts responsible for administration of the system may be members of the group.

Standard user accounts must not be members of the local administrator group.

If prohibited accounts are members of the local administrators group, this is a finding.

If the built-in Administrator account or other required administrative accounts are found on the system, this is not a finding.
"@
$msGroupCheck = @"
This applies to member servers. For domain controllers and standalone systems, this is NA.

If the following registry value does not exist or is not configured as specified, this is a finding.

Registry Hive:  HKEY_LOCAL_MACHINE
Registry Path:  \SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System

Value Name:  LocalAccountTokenFilterPolicy

Type:  REG_DWORD
Value: 0x00000000 (0)

"@
$allGroupCheck = @"
If the following registry value does not exist or is not configured as specified, this is a finding.

Registry Hive:  HKEY_LOCAL_MACHINE
Registry Path:  \SYSTEM\CurrentControlSet\Control\SecurityProviders\Wdigest\

Value Name:  UseLogonCredential

Type:  REG_DWORD
Value:  0x00000000 (0)
"@

$dcGroupContent  = (Get-Content -Path "$PSScriptRoot\..\..\..\data\samplegroup.xml.txt" -Encoding UTF8) -f "V-1","","","","", $dcGroupCheck
$msGroupContent  = (Get-Content -Path "$PSScriptRoot\..\..\..\data\samplegroup.xml.txt" -Encoding UTF8) -f "V-2", "", "", "", "", $msGroupCheck
$allGroupContent = (Get-Content -Path "$PSScriptRoot\..\..\..\data\samplegroup.xml.txt" -Encoding UTF8) -f "V-3", "", "", "", "", $allGroupCheck

# Stub the functions so they can be mocked without linking the files in multiple locations.
function Get-StigXccdfBenchmarkContent {}

Describe "ConvertFrom-StigXccdf" {
    # Mock the return xml title element 
    [xml] $xccdfContent = "<title>Test Title</title>"
    Mock -CommandName Get-StigXccdfBenchmarkContent -MockWith {return $xccdfContent}
}

Describe "Split-StigXccdf" {
    $TestFile = "$TestDrive\TextData.xml"
    $BaseFileContent -f "", "", "", ($dcGroupContent + $msGroupContent + $allGroupContent), "Windows_Server_2016_STIG" | Out-File -FilePath $TestFile
    
    Split-StigXccdf -Path $TestFile -Destination $TestDrive
    
    Context 'Member Server' {

        $SplitPath = "$TestDrive\Windows_Server_2016_STIG_MS.xml"

        It "Should split a Windows Server 2016 STIG into an MS stig files" {
            Test-Path -Path $SplitPath | Should Be $true 
        }
        
        It "Should not have a Domain Controller only setting" {
            [xml] $xccdf = Get-Content -Path $SplitPath -Encoding UTF8
            $xccdf.Benchmark.Group.where( {$PSItem.id -eq "V-1"} ) | Should BeNullOrEmpty
        }
    }
    
    Context 'Domain Controller' {

        $SplitPath = "$TestDrive\Windows_Server_2016_STIG_DC.xml"
        
        It "Should split a Windows Server 2016 STIG into an DC stig files" {
            Test-Path -Path $SplitPath | Should Be $true 
        }

        It "Should not have a Member Server only setting" {
            [xml] $xccdf = Get-Content -Path $SplitPath -Encoding UTF8
            $xccdf.Benchmark.Group.where( {$PSItem.id -eq "V-2"} ) | Should BeNullOrEmpty
        }
    }
}
