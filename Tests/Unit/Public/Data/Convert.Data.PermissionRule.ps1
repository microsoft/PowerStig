#region Header
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Tests

Describe "fileRightsConstant Data Section" {
    
    [string] $dataSectionName = 'fileRightsConstant'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "registryRightsConstant Data Section" {
    
    [string] $dataSectionName = 'registryRightsConstant'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "activeDirectoryRightsConstant Data Section" {
    
    [string] $dataSectionName = 'activeDirectoryRightsConstant'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "inheritenceConstant Data Section" {
    
    [string] $dataSectionName = 'inheritenceConstant'

    It "Should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}
#endregion Tests
