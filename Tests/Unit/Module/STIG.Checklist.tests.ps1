#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

Describe 'New-StigCheckList' {
    # Test parameter -MofFile

    # Test parameter -DscResult

    # Test parameter -XccdfPath

    # Test parameter -ChecklistSTIGFiles

    # Test parameter validity -OutputPath
    It 'Should throw if an invalid path is provided' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -OutputPath 'c:\asdf'} | Should Throw
    }

    It 'Should throw if the full path to a .ckl file is not provided' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -OutputPath 'c:\test\test.ck'} | Should Throw
    }

    # Test parameter -ManualCheckFile
    It 'Should throw if the full path to a ManualCheckFile is not valid' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -ManualCheckFile 'broken' -OutputPath 'c:\test\test.ck'} | Should Throw
    }

    # Test invalid parameter combinations
    It 'Should throw if an invalid combination of parameters for assessment is provided' {
        {New-StigChecklist -MofFile 'test' -DscResults 'test' -XccdfPath 'test' -OutputPath 'C:\test'} | should throw
    }

    It 'Should throw if an invalid combination of parameters for Xccdf validation is provided' {
        {New-StigCheckList -DscResult 'foo' -MofFile 'bar' -OutputPath 'C:\Test'} | Should throw
    }
}

Describe 'Get-TargetNodeType' {
    # Parameter [string]$targetNode should produce one of 5 different results

}

Describe 'Get-VulnerabilityList' {
    # Parameter [psobject]$XccdfBenchmark - Test to see if there is an element $XccdfBenchmark.Group - if not then it isn't a valid file.

}

Describe 'Get-SettingsFromMof' {
    # Parameter [string]$Id should be in a valid VulnId format
    # Parameter for a MofFile should determine that it is a valid mof file before continuing

}

Describe 'Get-SettingsFromResult' {
    # Parameter [string]$Id should be in a valid VulnId format
    # Parameter [psobject]$DscResult should have $dscResult.ResourcesNotInDesiredState and/or $dscResult.ResourcesInDesiredState.
    # if it is empty then we have either an empty result file or an invalid object.

}

Describe 'Get-FindingDetails' {
    # - parameter [psobject]$setting - test for $setting.ResourceID
    # - if not present, is not a valid object
}

Describe 'Get-FindingDetailsString' {
    # - parameter [psobject]$setting - test for .psobject.properties - should exist
}

Describe 'Get-MofContent' {
    # - parameter [string]$ReferenceConfiguration
    # - could be invalid
    # - could fail to convert to Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache

}

<#
    Describe 'Get-StigXccdfBenchmarkContent' {

        InModuleScope $script:moduleName {
            [xml]$xccdfTestContent = '<?xml version="1.0" encoding="utf-8"?><Benchmark><title>Test Title</title></Benchmark>'
            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-StigContentFromZip -MockWith { return $xccdfTestContent }
            Mock -CommandName Get-Content -MockWith { return $xccdfTestContent }
    
            It 'Should throw if the path is not found' {
                Mock -CommandName Test-Path -MockWith { return $false }
                { Get-StigXccdfBenchmarkContent -Path C:\Not\Found\file.xml } | Should Throw
            }
    
            It 'Should extract the xccdf from a ZIP' {
                Mock -CommandName Test-Path -MockWith { $true }
                $return = Get-StigXccdfBenchmarkContent -Path 'C:\download.zip'
                $return.title | Should Be 'Test Title'
            }
        }
    }
    
    Describe 'Get-StigContentFromZip' {
    
        InModuleScope $script:moduleName {
            Mock -CommandName Expand-Archive -MockWith { return }
            Mock -CommandName Get-ChildItem -MockWith { return @{fullName = 'C:\file-Manual-xccdf.xml'} }
            Mock -CommandName Get-Content -MockWith { return 'Test XML'}
            Mock -CommandName Remove-Item -MockWith { return }
    
            It 'Should Extract the xccdf from the zip' {
                $return = Get-StigContentFromZip -Path C:\Path\to\file.zip
                $return | Should Be 'Test XML'
            }
        }
    }

    It 'Should exist' {
        Get-Command -Name Get-OrganizationValueTestString | Should Not BeNullOrEmpty
    }
    #>
