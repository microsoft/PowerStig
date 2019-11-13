. $PSScriptRoot\..\..\..\Module\STIG\Functions.Checklist.ps1

Describe 'New-StigCheckList' {

    It 'Should throw if an invalid path is provided' {
        Mock Test-Path {return $false}
        {New-StigCheckList -ReferenceConfiguration 'test' -XccdfPath 'test' -OutputPath 'c:\test'} | Should Throw
    }

    It 'Should throw if the full path to a .ckl file is not provided' {
        Mock Test-Path {return $true}
        {New-StigCheckList -ReferenceConfiguration 'test' -XccdfPath 'test' -OutputPath 'c:\test\test.ck'} | Should Throw
    }

    It 'Should throw if the full path to a ManualCheckFile is not valid' {
        Mock Test-Path {return $true}
        {New-StigCheckList -ReferenceConfiguration 'test' -XccdfPath 'test' -ManualCheckFile 'broken' -OutputPath 'c:\test\test.ck'} | Should Throw
    }
}
