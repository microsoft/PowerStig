#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

Describe 'Backup-StigSettings' {

    $get = @{
        MitigationValue = "False"
    }
    Mock -CommandName Invoke-DscResource -MockWith {return $get}

    It 'Should not throw' {
            {Backup-StigSettings -StigName "WindowsServer-2019-MS-2.2.xml"}| Should -not -Throw
        }

        $test = Get-ChildItem $ENV:TEMP | Where-Object Name -like *.csv
        It 'Should create a backup of current STIG Settings' {
            $test | Should -Not -BeNullOrEmpty
        }
}

Describe 'Restore-StigSettings' {
    It 'Should not throw' {
        {Restore-StigSettings -StigName "WindowsServer-2019-MS-2.2.xml"} | Should -Not -Throw
    }
}
