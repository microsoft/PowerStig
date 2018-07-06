#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.ps1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module $modulePath -Force
#endregion


Describe 'Get-StigXccdfBenchmarkContent' {

    $path = "TestDrive:\stig.zip"

    It "Should throw an error when an invalid path is given." {
        Mock -CommandName Test-Path -MockWith {$false}
        {Get-StigXccdfBenchmarkContent -Path $path} | Should Throw
    }

    It "Should call Get-StigContentFromZip if a zip file is provided." {
        Mock -CommandName Test-Path -MockWith {$true}
        Mock -CommandName Get-StigContentFromZip -MockWith {return "<Benchmark></Benchmark>"} -Verifiable
        Mock -CommandName Test-ValidXccdf -MockWith {return $true}
        Get-StigXccdfBenchmarkContent -Path $path
        Assert-VerifiableMock
    }

    It "Should call Get-Content if a xml file is provided." {
        Mock -CommandName Test-Path -MockWith {$true}
        Mock -CommandName Get-Content -MockWith {return "<Benchmark></Benchmark>"} -Verifiable
        Mock -CommandName Test-ValidXccdf -MockWith {return $true}
        Get-StigXccdfBenchmarkContent -Path "TestDrive:\stig-xccdf.xml"
        Assert-VerifiableMock
    }

    It "Should thrown an error if the xccdf is invalid " {
        Mock -CommandName Test-Path -MockWith {$true}
        Mock -CommandName Get-Content -MockWith {return "<Benchmark></Benchmark>"} -Verifiable
        Mock -CommandName Test-ValidXccdf -MockWith {return $false}
        {Get-StigXccdfBenchmarkContent -Path "TestDrive:\stig-xccdf.xml"} | Should Throw
    }
}

Describe 'Get-StigContentFromZip' {

}

Describe 'Test-ValidXccdf' {

    It "Should return $true if all requires elements are found" {
        [xml] $xccdfXmlContent = "
            <benchmark>
                <title>Test Title</title>
                <version>1</version>
                <group>Rules would go here</group>
            </benchmark>"
        Test-ValidXccdf -xccdfXmlContent $xccdfXmlContent | Should Be $true
    }
    
    It "Should return $false if the title element is not found" {
        [xml] $xccdfXmlContent = "<title>Test Title</title>"
        Test-ValidXccdf -xccdfXmlContent $xccdfXmlContent| Should Be $false
    }

    It "Should return $false if the version element is not found" {
        [xml] $xccdfXmlContent = "<version>1</version>"
        Test-ValidXccdf -xccdfXmlContent $xccdfXmlContent| Should Be $false
    }

    It "Should return $false if the group element is not found" {
        [xml] $xccdfXmlContent = "<group>Rules goes here</group>"
        Test-ValidXccdf -xccdfXmlContent $xccdfXmlContent| Should Be $false
    }
}
