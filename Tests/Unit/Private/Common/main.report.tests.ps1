# Build the path to the system under test
[string] $sut = $MyInvocation.MyCommand.Path -replace '\\tests\\','\src\' `
                                             -replace '\.tests','' `
                                             -replace '\\unit\\','\'
# load the system under test
. $sut

Describe "Get-RuleTypeList" {

    It "Should exist" {
        Get-Command Get-RuleTypeList | Should Not BeNullOrEmpty
    }

    $Global:stigSettings = @(
        @{
            id       = 'V-1000'
            RuleType = 'RegistryRule'
        },
        @{
            id       = 'V-1001'
            RuleType = 'RegistryRule'
        },
        @{
            id       = 'V-1002'
            RuleType = 'AuditPolicyRule'
        }
    )

    It "Should return alphabetical list of STIG Types " {
        #(Get-RuleTypeList -StigSettings $Global:stigSettings)[0] | Should Be "AuditPolicyRule"
        #(Get-RuleTypeList -StigSettings $Global:stigSettings)[1] | Should Be "RegistryRule"
    }
}
