#region Header
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Tests

Describe "xmlAttribute Data Section" {
    
    [string] $dataSectionName = 'xmlAttribute'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "xmlElement Data Section" {
    
    [string] $dataSectionName = 'xmlElement'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "DscResourceModule Data Section" {
    
    [string] $dataSectionName = 'DscResourceModule'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "DscResource Data Section" {
    
    [string] $dataSectionName = 'DscResource'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}
#endregion Tests
