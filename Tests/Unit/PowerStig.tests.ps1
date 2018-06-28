
$script:ModuleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', ''

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot )
$script:moduleManifestPath = "$($script:moduleRoot)\$ModuleName.psd1"
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'Tests\helper.psm1') -Force
#endregion


Describe 'Project' {

    It 'Contains a readme' {
        Test-Path "$($script:moduleRoot)\README.md" | Should Be True
    }

    Context "$Name manifest properties" {

        It 'Should contains a valid module manifest.' {
            {$script:manifest = Test-ModuleManifest -Path $script:moduleManifestPath} | Should Not Throw
        }
        It 'Should have a GUID in the manifest' {
            $script:manifest.GUID | Should Match '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'
        }
        It 'Should not have required modules' {
            $script:manifest.RequiredModules | Should BeNullOrEmpty
        }
        It 'Should list production module version' {
            ($script:manifest.Version -ge "1.0.0.0") | Should Be True
        }
        It 'Should list an author in the manifest' {
            $script:manifest.Author | Should Not Be Null
        }
        It 'Should provide a description in the manifest' {
            $script:manifest.Description | Should Not Be Null
        }
        It 'Should require PowerShell version 5 or later in the manifest' {
            ($script:manifest.PowerShellVersion -ge 5.0.0.0) | Should Be True
        }
        It 'Should require CLR version 4 or later in the manifest' {
            ($script:manifest.CLRVersion -ge 4.0.0.0) | Should Be True
        }
        It 'Should export functions in the manifest' {
            $script:manifest.FunctionsToExport | Should Not Be Null
        }
        It 'Should include tags in the manifest' {
            $script:manifest.PrivateData.PSData.Tags | Should Not Be Null
        }
        It 'Should include a project URI in the manifest' {
            $script:manifest.PrivateData.PSData.ProjectURI | Should Not Be Null
        }
    }

    if ($Manifest.RequiredModules)
    {
        Context "$Name required modules" {

            foreach ($RequiredModule in $Manifest.RequiredModules)
            {
                if ($RequiredModule.GetType().Name -eq 'Hashtable')
                {
                    It "$($RequiredModule.ModuleName) version $($RequiredModule.ModuleVersion) should be found in the PowerShell public gallery" {
                        {Find-Module -Name $RequiredModule.ModuleName -RequiredVersion $RequiredModule.ModuleVersion} | Should Not Be Null
                    }
                    It "$($RequiredModule.ModuleName) version $($RequiredModule.ModuleVersion) should install locally without error" {
                        {Install-Module -Name $RequiredModule.ModuleName -RequiredVersion $RequiredModule.ModuleVersion -Scope CurrentUser -Force} | Should Not Throw
                    }
                }
                else
                {
                    It "$RequiredModule should be found in the PowerShell public gallery" {
                        {Find-Module -Name $RequiredModule} | Should Not Be Null
                    }
                    It "$RequiredModule should install locally without error" {
                        {Install-Module -Name $RequiredModule -Scope CurrentUser -Force} | Should Not Throw
                    }
                }
            }
        }
    }
}
