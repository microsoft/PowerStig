#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

Describe 'Backup-StigSettings' {

    $get = @{
        MitigationValue = "False"
    }

    Mock Invoke-DscResource -MockWith { return $get }

    It 'Should not throw WindowsServer' {
        {Backup-StigSettings -StigName "WindowsServer-2019-MS-2.7.xml"} | Should -not -Throw
    }

    It 'Should not throw WindowsClient' {
        {Backup-StigSettings -StigName "WindowsClient-10-2.7.xml"} | Should -not -Throw
    }

    It 'Should not throw Sql Server 2016' {
        {Backup-StigSettings -StigName "SqlServer-2016-Instance-2.3.xml"} | Should -not -Throw
    }

    It 'Should return string with valid STIGs' {
        Backup-StigSettings -StigName "wrong.xml" | Should -BeOfType System.String
    }

    $test = Get-ChildItem $ENV:TEMP | Where-Object Name -like *.csv
    It 'Should create a backup of current STIG Settings' {
        $test | Should -Not -BeNullOrEmpty
    }
}

Describe 'Restore-StigSettings' {

    $get = @{
        MitigationValue = "False"
    }

    Mock -CommandName Invoke-DscResource -MockWith {return $get}

    It 'Should not throw for Server' {
        {Restore-StigSettings -StigName "WindowsServer-2019-MS-2.7.xml" -Confirm:$false} | Should -Not -Throw
    }

    It 'Should not throw for Client' {
        {Restore-StigSettings -StigName "WindowsClient-10-2.7.xml" -Confirm:$false} | Should -Not -Throw
    }

    It 'Should not throw for Sql Server 2016' {
        {Restore-StigSettings -StigName "SqlServer-2016-Instance-2.3.xml" -Confirm:$false} | Should -Not -Throw
    }

}
