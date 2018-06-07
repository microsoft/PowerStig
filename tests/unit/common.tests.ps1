# Pulled from https://github.com/PowerShell/DscConfiguration.Tests

<#
    PSSA = PS Script Analyzer
    Only the first and last tests here will pass/fail correctly at the moment. The other 3 tests
    will currently always pass, but print warnings based on the problems they find.
    These automatic passes are here to give contributors time to fix the PSSA
    problems before we turn on these tests. These 'automatic passes' should be removed
    along with the first test (which is replaced by the following 3) around Jan-Feb
    2017.
#>

$projectRoot = (Resolve-Path -Path $PSScriptRoot\..\..\).Path

$srcDirectory = "$projectRoot\src"
<#
    .SYNOPSIS
        Retrieves the parse errors for the given file.

    .PARAMETER FilePath
        The path to the file to get parse errors for.
#>
function Get-FileParseErrors
{
    [OutputType([System.Management.Automation.Language.ParseError[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [String]
        $FilePath
    )

    $parseErrors = $null

    $null = [System.Management.Automation.Language.Parser]::ParseFile(
            $FilePath,
            [ref] $null,
            [ref] $parseErrors
    )
    return $parseErrors
}

<#
    .SYNOPSIS
        Retrieves all text files under the given root file path.

    .PARAMETER Root
        The root file path under which to retrieve all text files.

    .NOTES
        Retrieves all files with the '.gitignore', '.gitattributes', '.ps1', '.psm1', '.psd1',
        '.json', '.xml', '.cmd', or '.mof' file extensions.
#>
function Get-TextFilesList
{
    [OutputType([System.IO.FileInfo[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $FilePath
    )

    $textFileExtensions = @('.gitignore', '.gitattributes', '.ps1', '.psm1', '.psd1', '.json',
    '.xml', '.cmd', '.mof')

    return Get-ChildItem -Path $FilePath -File -Recurse | Where-Object { $textFileExtensions `
    -contains $_.Extension }
}
function Test-FileInUnicode
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [System.IO.FileInfo]
        $FileInfo
    )

    $filePath = $FileInfo.FullName

    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)

    $zeroBytes = @( $fileBytes -eq 0 )

    return ($zeroBytes.Length -ne 0)
}

if(-not $env:SrcFolder)
{
    $env:SrcFolder = $srcDirectory
}

$Name = 'PowerStig'

Describe 'Common Tests - File Parsing' {
    $ScriptFiles = Get-ChildItem -Path $env:SrcFolder -Filter '*.ps1' -File

    foreach ($ScriptFile in $ScriptFiles)
    {
        Context $ScriptFile.Name {
            It 'Should not contain parse errors' {
                $containsParseErrors = $false

                $parseErrors = Get-FileParseErrors -FilePath $ScriptFile.FullName

                if ($null -ne $parseErrors)
                {
                    Write-Warning -Message "There are parse errors in $($ScriptFile.FullName):"
                    Write-Warning -Message ($parseErrors | Format-List | Out-String)

                    $containsParseErrors = $true
                }

                $containsParseErrors | Should Be $false
            }
        }
    }
}

<#
#>
Describe 'Common Tests - File Formatting' {
    $textFiles = Get-TextFilesList -FilePath $env:SrcFolder

    Context 'All discovered ext files' {
        It "Should not contain any files with Unicode file encoding" {
            $containsUnicodeFile = $false

            foreach ($textFile in $textFiles)
            {
                if (Test-FileInUnicode $textFile) {
                    if($textFile.Extension -ieq '.mof')
                    {
                        Write-Warning -Message "File $($textFile.FullName) should be converted to ASCII. Use fixer function 'Get-UnicodeFilesList `$pwd | ConvertTo-ASCII'."
                    }
                    else
                    {
                        Write-Warning -Message "File $($textFile.FullName) should be converted to UTF-8. Use fixer function 'Get-UnicodeFilesList `$pwd | ConvertTo-UTF8'."
                    }

                    $containsUnicodeFile = $true
                }
            }

            $containsUnicodeFile | Should Be $false
        }

        It 'Should not contain any files with tab characters' {
            $containsFileWithTab = $false

            foreach ($textFile in $textFiles)
            {
                $fileName = $textFile.FullName
                $fileContent = Get-Content -Path $fileName -Raw

                $tabCharacterMatches = $fileContent | Select-String "`t"

                if ($null -ne $tabCharacterMatches)
                {
                    Write-Warning -Message "Found tab character(s) in $fileName. Use fixer function 'Get-TextFilesList `$pwd | ConvertTo-SpaceIndentation'."
                    $containsFileWithTab = $true
                }
            }

            $containsFileWithTab | Should Be $false
        }

        It 'Should not contain empty files' {
            $containsEmptyFile = $false

            foreach ($textFile in $textFiles)
            {
                $fileContent = Get-Content -Path $textFile.FullName -Raw

                if([String]::IsNullOrWhiteSpace($fileContent))
                {
                    Write-Warning -Message "File $($textFile.FullName) is empty. Please remove this file."
                    $containsEmptyFile = $true
                }
            }

            $containsEmptyFile | Should Be $false
        }
        <#
        It 'Should not contain files without a newline at the end' {
            $containsFileWithoutNewLine = $false

            foreach ($textFile in $textFiles)
            {
                $fileContent = Get-Content -Path $textFile.FullName -Raw

                if(-not [String]::IsNullOrWhiteSpace($fileContent) -and $fileContent[-1] -ne "`n")
                {
                    if (-not $containsFileWithoutNewLine)
                    {
                        Write-Warning -Message 'Each file must end with a new line.'
                    }

                    Write-Warning -Message "$($textFile.FullName) does not end with a new line. Use fixer function 'Add-NewLine'"

                    $containsFileWithoutNewLine = $true
                }
            }


            $containsFileWithoutNewLine | Should Be $false
        }
        #>
    }
}

Describe 'Common Tests - Configuration Module Requirements' {

    #$Name = Get-Item -Path $env:SrcFolder | ForEach-Object -Process {$_.Name}

    $Files = Get-ChildItem -Path $env:SrcFolder
    $Manifest = Import-PowerShellDataFile -Path "$env:SrcFolder\$Name.psd1"

    Context "$Name module manifest properties" {
        It 'Contains a module manifest that aligns to the folder and module names' {
            $Files.Name.Contains("$Name.psd1") | Should Be True
        }
        It 'Contains a readme' {
            Test-Path "$projectRoot\README.md" | Should Be True
        }
        It "Manifest $Name.psd1 should import as a data file" {
            $Manifest | Should BeOfType 'Hashtable'
        }
        It 'Should have a GUID in the manifest' {
            $Manifest.GUID | Should Match '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'
        }
        It 'Should list requirements in the manifest' {
            $Manifest.RequiredModules | Should Not Be Null
        }
        It 'Should list a module version in the manifest' {
            $Manifest.ModuleVersion | Should BeGreaterThan 0.0.0.0
        }
        It 'Should list an author in the manifest' {
            $Manifest.Author | Should Not Be Null
        }
        It 'Should provide a description in the manifest' {
            $Manifest.Description | Should Not Be Null
        }
        It 'Should require PowerShell version 4 or later in the manifest' {
            $Manifest.PowerShellVersion | Should BeGreaterThan 4.0
        }
        It 'Should require CLR version 4 or later in the manifest' {
            $Manifest.CLRVersion | Should BeGreaterThan 4.0
        }
        It 'Should export functions in the manifest' {
            $Manifest.FunctionsToExport | Should Not Be Null
        }
        It 'Should include tags in the manifest' {
            $Manifest.PrivateData.PSData.Tags | Should Not Be Null
        }
        It 'Should include a project URI in the manifest' {
            $Manifest.PrivateData.PSData.ProjectURI | Should Not Be Null
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
