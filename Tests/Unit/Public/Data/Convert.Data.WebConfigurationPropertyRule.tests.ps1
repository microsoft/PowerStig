#region Header
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Tests
Describe "webRegularExpression Data Section" {
    
    [string] $dataSectionName = 'webRegularExpression'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "logflagsConstant Data Section" {
    
    [string] $dataSectionName = 'logflagsConstant'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}
#endregion Tests
