#region Header
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Tests
Describe "RegularExpression Data Section" {
    
    [string] $dataSectionName = 'RegularExpression'

    It "Should have a data section called $dataSectionName" {
        ( get-variable $dataSectionName ).Name | Should Be $dataSectionName
    }

    Context 'Hex Code' {

        It 'Should match a hexcode' {
            '0X00000000' -Match $RegularExpression.hexCode | Should Be $true  
        }

        It 'Should NOT match nonhexcode' {
            '0X000000000' -Match $RegularExpression.hexCode | Should Be $false  
        }
    }

    Context 'Leading Integer Unbound' {

    }

    Context 'Text Between Quotes' {

        It "Should match string with double quotes" {
            'hello "this" test' -Match $RegularExpression.textBetweenQuotes | Should Be $true
        }

        It "Should match string with single quotes" {
            "hello 'this' test" -Match $RegularExpression.textBetweenQuotes | Should Be $true
        }
    }

    Context "Blank String" {
        
        It "Should match '(Blank)' literal string" {
            "(Blank)" -Match $RegularExpression.blankString | Should Be $true
        }
    }
    
    Context 'Enabled or Disabled String' {

        foreach ( $flag in ('Enabled','enabled','Disabled','disabled') )
        {
            It "Should match the exact string '$flag'" {
                $flag -Match $RegularExpression.enabledOrDisabled | Should Be $true
            }
        }
    }

    Context 'Audit Policy' {

        foreach ( $flag in ('Success','success','Failure','failure') )
        {
            It "Should match the exact string '$flag'" {
                $flag -Match $RegularExpression.AuditFlag | Should Be $true
            }
        }
        
        $audiPolicyStringFormats = @(
            'Catagory -> Sub Category - Flag',
            'Catagory >> Sub Category - Flag'
        )

        foreach ($audiPolicyStringFormat in $audiPolicyStringFormats)
        {
            It "Should match the string '$audiPolicyStringFormat'" {
                $audiPolicyStringFormat -Match $RegularExpression.getAuditPolicy | Should Be $true
            }
        }
    }

    Context "TextBetweenParentheses string matches" {

        It 'Should match string inside parentheses' {
            '(text inside parentheses)' -Match $RegularExpression.textBetweenParentheses | Should Be $true
        }

        It 'Should NOT match text outside of parentheses' {
            'text outside ()' -Match $RegularExpression.textBetweenParentheses | Should Be $false
        }

        It 'Should NOT match text inside improperly written parentheses' {
            ')text(' -Match $RegularExpression.textBetweenParentheses | Should Be $false
        }

        It 'Should return text inside of parentheses when grabbing the last group' {
            $text = 'InsideOfParenthese'
            $unneededText = 'Unneeded text'

            $result = ( "$unneededText (" + $text + ") $unneededText" | 
                Select-String $RegularExpression.textBetweenParentheses ).matches.groups[-1].Value

            $result | Should Be $text
        }
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "rangeMatch Data Section" {
    
    [string] $dataSectionName = 'rangeMatch'

    It "should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "errorMessage Data Section" {
    
    [string] $dataSectionName = 'errorMessage'

    It "should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}

Describe "ADAuditPath Data Section" {
    
    [string] $dataSectionName = 'ADAuditPath'

    It "should have a data section called $dataSectionName" {
        ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
    }

    <# 
    TO DO - Add rules 
    #>
}
#endregion Tests
