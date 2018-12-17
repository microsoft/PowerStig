$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $ConfigFile

    $StigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    #region Integration Tests
    foreach ($Stig in $StigList)
    {
        Describe "Framework $($Stig.TechnologyRole) $($Stig.StigVersion) mof output" {

        It 'Should compile the MOF without throwing' {
            {
                & "$($script:DSCCompositeResourceName)_config" `
                -FrameworkVersion $Stig.TechnologyRole `
                -StigVersion $Stig.StigVersion `
                -OutputPath $TestDrive
            } | Should -Not -Throw
        }

        [xml] $DscXml = Get-Content -Path $Stig.Path

        $ConfigurationDocumentPath = "$TestDrive\localhost.mof"

        $Instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ConfigurationDocumentPath, 4)

        Context 'Registry' {
            $HasAllSettings = $true
            $DscXml = @($DscXml.DISASTIG.RegistryRule.Rule)
            $DscMof = $Instances |
                Where-Object {$PSItem.ResourceID -match "\[xRegistry\]"}

            foreach ($Setting in $DscXml)
            {
                If (-not ($DscMof.ResourceID -match $Setting.Id) )
                {
                    Write-Warning -Message "Missing registry Setting $($Setting.Id)"
                    $HasAllSettings = $false
                }
            }

            It "Should have $($DscXml.Count) Registry settings" {
                $HasAllSettings | Should -Be $true
            }
        }
    }
}
#endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

