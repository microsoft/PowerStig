#region HEADER
# Convert Public Class Header V1
using module ..\..\..\..\Public\Common\enum.psm1
. $PSScriptRoot\..\..\..\..\Public\Common\data.ps1
$ruleClassName = ($MyInvocation.MyCommand.Name -Split '\.')[0]

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.psm1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
#endregion
#region Tests
Describe "UserRightNameToConstant Data Section" {
    
    [string] $dataSectionName = 'UserRightNameToConstant'

	It "should have a data section called $dataSectionName" {
	    ( Get-Variable $dataSectionName ).Name | Should Be $dataSectionName
	}

    <# 
    TO DO - Add rules 
    #>
}


Describe "auditPolicySubcategories Data Section" {
    
    [string] $dataSectionName = 'auditPolicySubcategories'

	It "should have a data section called $dataSectionName" {
	    ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
	}

    <# 
    TO DO - Add rules 
    #>
}

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
