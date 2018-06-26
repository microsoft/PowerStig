$script:DSCModuleName            = 'PowerStigDsc'
$script:DSCCompositeResourceName = 'Browser'

#region HEADER
# Integration Test Template Version: 1.1.1
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\helper.psm1' ) -Force
Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

#endregion

$projectRoot = (Resolve-Path -Path $PSScriptRoot\..\..).Path
$SrcRootDir = "$projectRoot"
$ModuleName = (Get-Item $SrcRootDir/*.psd1).BaseName

Import-Module "$projectRoot\tests\helper.psm1" -Force

# Describe 'Common Tests - File Parsing' {
#     $ScriptFiles = Get-ChildItem -Path $relDirectory -Filter '*.ps1' -File

#     foreach ($ScriptFile in $ScriptFiles)
#     {
#         Context $ScriptFile.Name {
#             It 'Should not contain parse errors' {
#                 $containsParseErrors = $false

#                 $parseErrors = Get-FileParseErrors -FilePath $ScriptFile.FullName

#                 if ($null -ne $parseErrors)
#                 {
#                     Write-Warning -Message "There are parse errors in $($ScriptFile.FullName):"
#                     Write-Warning -Message ($parseErrors | Format-List | Out-String)

#                     $containsParseErrors = $true
#                 }

#                 $containsParseErrors | Should Be $false
#             }
#         }
#     }
# }

# Describe 'Common Tests - File Formatting' {
#     $textFiles = Get-TextFilesList -FilePath $relDirectory

#     Context 'All discovered ext files' {
#         It "Should not contain any files with Unicode file encoding" {
#             $containsUnicodeFile = $false

#             foreach ($textFile in $textFiles)
#             {
#                 if (Test-FileInUnicode $textFile) {
#                     if($textFile.Extension -ieq '.mof')
#                     {
#                         Write-Warning -Message "File $($textFile.FullName) should be converted to ASCII. Use fixer function 'Get-UnicodeFilesList `$pwd | ConvertTo-ASCII'."
#                     }
#                     else
#                     {
#                         Write-Warning -Message "File $($textFile.FullName) should be converted to UTF-8. Use fixer function 'Get-UnicodeFilesList `$pwd | ConvertTo-UTF8'."
#                     }

#                     $containsUnicodeFile = $true
#                 }
#             }

#             $containsUnicodeFile | Should Be $false
#         }

#         It 'Should not contain any files with tab characters' {
#             $containsFileWithTab = $false

#             foreach ($textFile in $textFiles)
#             {
#                 $fileName = $textFile.FullName
#                 $fileContent = Get-Content -Path $fileName -Raw

#                 $tabCharacterMatches = $fileContent | Select-String "`t"

#                 if ($null -ne $tabCharacterMatches)
#                 {
#                     Write-Warning -Message "Found tab character(s) in $fileName. Use fixer function 'Get-TextFilesList `$pwd | ConvertTo-SpaceIndentation'."
#                     $containsFileWithTab = $true
#                 }
#             }

#             $containsFileWithTab | Should Be $false
#         }

#         It 'Should not contain empty files' {
#             $containsEmptyFile = $false

#             foreach ($textFile in $textFiles)
#             {
#                 $fileContent = Get-Content -Path $textFile.FullName -Raw

#                 if([String]::IsNullOrWhiteSpace($fileContent))
#                 {
#                     Write-Warning -Message "File $($textFile.FullName) is empty. Please remove this file."
#                     $containsEmptyFile = $true
#                 }
#             }

#             $containsEmptyFile | Should Be $false
#         }

#         It 'Should not contain files without a newline at the end' {
#             $containsFileWithoutNewLine = $false

#             foreach ($textFile in $textFiles)
#             {
#                 # Skip xml files in this test
#                 if ($textFile.Extension -eq ".xml")
#                 {
#                     continue
#                 }
#                 $fileContent = Get-Content -Path $textFile.FullName -Raw
#                 if ( -not [String]::IsNullOrWhiteSpace($fileContent) -and $fileContent[-1] -ne "`n")
#                 {
#                     if (-not $containsFileWithoutNewLine)
#                     {
#                         Write-Warning -Message 'Each file must end with a new line.'
#                     }

#                     Write-Warning -Message "$($textFile.FullName) does not end with a new line. Use fixer function 'Add-NewLine'"

#                     $containsFileWithoutNewLine = $true
#                 }
#             }


#             $containsFileWithoutNewLine | Should Be $false
#         }

#     }
# }

# Describe 'Common Tests - Configuration Module Requirements' {

#     #$moduleName = Get-Item -Path $relDirectory | ForEach-Object -Process {$_.Name}

#     $Files = Get-ChildItem -Path $relDirectory
#     $Manifest = Import-PowerShellDataFile -Path "$relDirectory\$moduleName.psd1"

#     Context "$moduleName module manifest properties" {
#         It 'Contains a module manifest that aligns to the folder and module names' {
#             $Files.Name.Contains("$moduleName.psd1") | Should Be True
#         }
#         It 'Contains a readme' {
#             Test-Path "$projectRoot\README.md" | Should Be True
#         }
#         It "Manifest $moduleName.psd1 should import as a data file" {
#             $Manifest | Should BeOfType 'Hashtable'
#         }
#         It 'Should have a GUID in the manifest' {
#             $Manifest.GUID | Should Match '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'
#         }
#         It 'Should not list RequiredModules in the manifest' {
#             $Manifest.RequiredModules | Should BeNullOrEmpty
#         }
#         It 'Should list a module version in the manifest' {
#             $Manifest.ModuleVersion | Should BeGreaterThan 0.0.0.0
#         }
#         It 'Should list an author in the manifest' {
#             $Manifest.Author | Should Not BeNullOrEmpty
#         }
#         It 'Should provide a description in the manifest' {
#             $Manifest.Description | Should Not BeNullOrEmpty
#         }
#         It 'Should require PowerShell version 4 or later in the manifest' {
#             $Manifest.PowerShellVersion | Should BeGreaterThan 4.0
#         }
#         It 'Should require CLR version 4 or later in the manifest' {
#             $Manifest.CLRVersion | Should BeGreaterThan 4.0
#         }
#         It 'Should export functions in the manifest' {
#             $Manifest.FunctionsToExport | Should Not BeNullOrEmpty
#         }
#         It 'Should include tags in the manifest' {
#             $Manifest.PrivateData.PSData.Tags | Should Not BeNullOrEmpty
#         }
#         It 'Should include a project URI in the manifest' {
#             $Manifest.PrivateData.PSData.ProjectURI | Should Not BeNullOrEmpty
#         }
#     }

#     if ($Manifest.RequiredModules)
#     {
#         Context "$moduleName required modules" {

#             foreach ($RequiredModule in $Manifest.RequiredModules)
#             {
#                 if ($RequiredModule.GetType().Name -eq 'Hashtable')
#                 {
#                     It "$($RequiredModule.ModuleName) version $($RequiredModule.ModuleVersion) should be found in the PowerShell public gallery" {
#                         {Find-Module -Name $RequiredModule.ModuleName -RequiredVersion $RequiredModule.ModuleVersion} | Should Not BeNullOrEmpty
#                     }
#                     It "$($RequiredModule.ModuleName) version $($RequiredModule.ModuleVersion) should install locally without error" {
#                         {Install-Module -Name $RequiredModule.ModuleName -RequiredVersion $RequiredModule.ModuleVersion -Scope CurrentUser -Force} | Should Not Throw
#                     }
#                 }
#                 else
#                 {
#                     It "$RequiredModule should be found in the PowerShell public gallery" {
#                         {Find-Module -Name $RequiredModule} | Should Not BeNullOrEmpty
#                     }
#                     It "$RequiredModule should install locally without error" {
#                         {Install-Module -Name $RequiredModule -Scope CurrentUser -Force} | Should Not Throw
#                     }
#                 }
#             }
#         }
#     }
# }

Describe 'Common Tests - STIG Data Requirements' {
    Context 'Converted STIGs' {
        $stigDataFolder = "$moduleRoot\StigData"
        $convertedStigs = Get-ChildItem -Path $stigDataFolder -File | Where-Object {$_.Name -notmatch "\.org\.default\.xml?"}
        $orgSettings = Get-ChildItem -Path $stigDataFolder -File | Where-Object {$_.Name -match "\.org\.default\.xml?"}
        $orgSettings = $orgSettings.BaseName.ToLower()
        $convertedStigs = $convertedStigs.BaseName.ToLower()

        foreach ($stig in $convertedStigs)
        {
            It "$stig should have paired org settings file" {
                $testResult = $true

                if ($orgSettings.Contains(($stig + ".org.default"))) 
                {
                    continue 
                }
                else 
                {
                    $testResult = $false

                    Write-Warning -Message "$stig does not have an Org Setting xml. Run 'ConvertTo-DscStigXml' for $stig with the 'CreateOrgSettingsFile' Switch "
                }
                
                $testResult | Should Be $true
            }
        }
    }
}
