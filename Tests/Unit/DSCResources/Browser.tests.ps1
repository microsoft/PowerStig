$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
$compositeManifestPath = "$($script:moduleRoot)\DscResources\$script:DSCCompositeResourceName\$script:DSCCompositeResourceName.psd1"
$compositeSchemaPath   = "$($script:moduleRoot)\DscResources\$script:DSCCompositeResourceName\$script:DSCCompositeResourceName.schema.psm1"
# Header

Describe "$($script:DSCCompositeResourceName) Composite resource" {

    It 'Should be a valid manifest' {
        {Test-ModuleManifest -Path $compositeManifestPath} | Should Not Throw
    }

    It 'Should contain a schema module' {
        Test-Path -Path $compositeSchemaPath | Should Be $true
    }

    It 'Should contain a correctly named configuration' {
        $configurationName = Get-ConfigurationName -FilePath $compositeSchemaPath
        $configurationName | Should Be $script:DSCCompositeResourceName
    }

    It "Should match ValidateSet from PowerStig" {
        $validateSet = Get-StigVersionParameterValidateSet -FilePath $compositeSchemaPath
        $availableStigVersions = Get-ValidStigVersionNumbers -TechnologyRoleFilter 'IE'
        $validateSet | Should BeIn $availableStigVersions
    }
}
