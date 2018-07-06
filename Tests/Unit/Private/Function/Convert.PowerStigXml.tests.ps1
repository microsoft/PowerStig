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

# Import the base benchmark xml string data.
$BaseXccdfContent = Get-Content -Path "$moduleRoot\Tests\Data\sampleXccdf.xml.txt" -Encoding UTF8

Describe "New-OrganizationalSettingsXmlFile" {

    Mock -CommandName Get-StigObjectsWithOrgSettings -MockWith {}
    # Needs to be expanded to use sample data.
    It "Should exist" {
        Get-Command New-OrganizationalSettingsXmlFile | Should Not BeNullOrEmpty
    }
}

Describe "Get-StigVersionNumber" {
    # Needs to be expanded to use sample data.
    It "Should exist" {
        Get-Command Get-StigVersionNumber | Should Not BeNullOrEmpty
    }
}

Describe "Get-StigObjectsWithOrgSettings" {

    # Needs to be expanded to use sample data. 
    It "Should exist" {
        Get-Command  Get-StigObjectsWithOrgSettings | Should Not BeNullOrEmpty
    }
}

Describe "Get-CompositeTargetFolder" {

    $titleList = @{
        "Windows Server 2012/2012 R2 Domain Controller Security Technical Implementation Guide" = 'WindowsServerDC'
        "Windows Server 2012/2012 R2 Member Server Security Technical Implementation Guide"     = 'WindowsServerMS'
    }

    $TestFile = "TestDrive:\TextData.xml"

    foreach ($title in $titleList.GetEnumerator())
    {
        It "Should return '$($title.value)' from '$($title.key)' " {
            $BaseXccdfContent -f $title.key,'','','','' | Out-File $TestFile
            Get-CompositeTargetFolder -Path $TestFile | Should Be $title.Value
        }
    }
}

Describe "Get-OutputFileRoot" {

    # Needs to be expanded to use sample data. 
    It "Should exist" {
        Get-Command  Get-OutputFileRoot | Should Not BeNullOrEmpty
    }
}
