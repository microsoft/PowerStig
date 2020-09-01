#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

Describe 'New-StigCheckList' {
    # Test parameter validity -OutputPath
    It 'Should throw if an invalid path is provided' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -OutputPath 'c:\asdf'} | Should -Throw
    }

    It 'Should throw if the full path to a .ckl file is not provided' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -OutputPath 'c:\test\test.ck'} | Should -Throw
    }

    # Test parameter -ManualCheckFile
    It 'Should throw if the full path to a ManualCheckFile is not valid' {
        {New-StigCheckList -MofFile 'test' -XccdfPath 'test' -ManualCheckFile 'broken' -OutputPath 'c:\test\test.ck'} | Should -Throw
    }

    # Test invalid parameter combinations
    It 'Should throw if an invalid combination of parameters for assessment is provided' {
        {New-StigChecklist -MofFile 'test' -DscResults 'test' -XccdfPath 'test' -OutputPath 'C:\test'} | should -Throw
    }

    It 'Should throw if an invalid combination of parameters for Xccdf validation is provided' {
        {New-StigCheckList -DscResult 'foo' -MofFile 'bar' -OutputPath 'C:\Test'} | Should -Throw
    }
}

