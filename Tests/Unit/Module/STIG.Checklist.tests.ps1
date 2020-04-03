. $PSScriptRoot\.test.header.ps1
$functionCheckListFile = (Join-Path -Path $script:moduleRoot -ChildPath '\Module\STIG\Functions.Checklist.ps1')
. $functionCheckListFile

Describe 'New-StigCheckList' {

    It 'Should throw if an invalid path is provided' {
        {New-StigCheckList -ReferenceConfiguration 'test' -XccdfPath 'test' -OutputPath 'c:\test'} | Should Throw
    }

    It 'Should throw if the full path to a .ckl file is not provided' {
        {New-StigCheckList -ReferenceConfiguration 'test' -XccdfPath 'test' -OutputPath 'c:\test\test.ck'} | Should Throw
    }

    It 'Should throw if the full path to a ManualCheckFile is not valid' {
        {New-StigCheckList -ReferenceConfiguration 'test' -XccdfPath 'test' -ManualCheckFile 'broken' -OutputPath 'c:\test\test.ck'} | Should Throw
    }
}
