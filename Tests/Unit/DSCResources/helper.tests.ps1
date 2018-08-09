[String] $script:moduleRoot = Split-Path -Parent ( Split-Path -Parent $PSScriptRoot )

Import-Module -Name ( Join-Path -Path $moduleRoot -ChildPath 'DscResources\helper.psm1' )

Describe "Variables" {

    It 'Should export the resourcePath variable' {
        $resourcePath | Should Not BeNullOrEmpty
    }
}

Describe "Functions" {

    Context 'Get-ResourceTitle' {

        [xml] $xml = Get-Content -Path $PSScriptRoot\helper.tests.data.xml

        $title = Get-ResourceTitle -Rule $xml.DISASTIG.RegistryRule.Rule

        It 'Title Should Exist' {
            $title | Should Not BeNullOrEmpty
        }
    }

    Context 'Get-RuleClassData' {

        It 'Should Exist' {
            Get-Command 'Get-RuleClassData' | Should Not BeNullOrEmpty
        }
    }
}
