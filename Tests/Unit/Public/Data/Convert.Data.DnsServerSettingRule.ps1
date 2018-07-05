#region Header
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Tests
Describe "DnsServerSetting Data Section" {
    
    [string] $dataSectionName = 'DnsServerSetting'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}
#endregion Tests
