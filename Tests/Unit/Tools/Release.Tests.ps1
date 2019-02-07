if ($PSVersionTable.PSEdition -ne 'Core')
{
    return
}
$unitTestRoot = Split-Path -Path $PSScriptRoot -Parent
. "$unitTestRoot\.tests.header.ps1"

try
{
    InModuleScope $script:ModuleName {

        Describe 'Test-ModuleVersion' -Tag 'tools' {

            $manifestPath = "$TestDrive\testManifest.psd1"
            New-ModuleManifest -Path $manifestPath -ModuleVersion '1.0.0.0'
            $moduleVersion = '1.1.0.0'

            Mock -CommandName Get-GitBranch -MockWith { 'dev' }
            Mock -CommandName Set-GitBranch -MockWith { } -ParameterFilter {$Branch -eq 'master'} -Verifiable

            It 'Should change to the master branch if not already in it' {
                $null = Test-ModuleVersion -ModuleVersion $moduleVersion -ManifestPath $manifestPath
                Assert-VerifiableMock
            }
            It "Should return $true when the supplied module version is higher than the master branch manifest" {
                Test-ModuleVersion -ModuleVersion $moduleVersion -ManifestPath $manifestPath | Should Be $true
            }
            It "Should return $false when the supplied module version is NOT higher than the master branch manifest" {
                $moduleVersion = '1.0.0.0'
                Test-ModuleVersion -ModuleVersion $moduleVersion -ManifestPath $manifestPath | Should Be $false
            }
            It "Should import the manifest from `$PWD if a ManifestPath is not provided" {
                $mockGetChildItem = @{FullName = $manifestPath}
                Mock -CommandName Get-ChildItem -MockWith { return $mockGetChildItem } -Verifiable
                $null = Test-ModuleVersion -ModuleVersion $moduleVersion
                Assert-VerifiableMock
            }
        }

        Describe 'Get-PowerStigRepository' -Tag 'tools' {
            $mockGetCommand = @{
                'CommandType' = 'Application'
                'Name' = 'git.exe'
                'Version' = '2.15.1.2'
                'Source' = 'C:\Program Files\Git\cmd\git.exe'
            }

            It 'Should Throw if Git is not installed' {
                Mock -CommandName Get-Command -MockWith { return $null }
                { Get-PowerStigRepository } | Should Throw
            }

            $repositoryList = @(
                @{
                    Name = 'https://github.com/Microsoft/PowerStig.git'
                    Result = @{
                        'name'     = 'PowerStig'
                        'html_url' = 'https://github.com/Microsoft/PowerStig'
                        'api_url'  = 'https://api.github.com/repos/Microsoft/PowerStig'
                    }
                },
                @{
                    Name = 'https://github.com/Microsoft/PowerStigDsc.git'
                    Result = @{
                        'name'     = 'PowerStigDsc'
                        'html_url' = 'https://github.com/Microsoft/PowerStigDsc'
                        'api_url'  = 'https://api.github.com/repos/Microsoft/PowerStigDsc'
                    }
                }
            )

            foreach ($repository in $repositoryList)
            {
                Mock -CommandName Get-Command -MockWith { return $mockGetCommand }
                Mock -CommandName Invoke-Command -MockWith { return $repository.Name }
                Mock -CommandName Invoke-Git -MockWith { $repository.Name}
                $PowerStigRepository = Get-PowerStigRepository

                It 'Should return the correct name' {
                    $PowerStigRepository.name | Should Be $repository.Result.name
                }
                It 'Should return the correct html URL' {
                    $PowerStigRepository.html_url | Should Be $repository.Result.html_url
                }
                It 'Should return the correct Api URL' {
                    $PowerStigRepository.api_url | Should Be $repository.Result.api_url
                }
            }

            It 'Should throw an error if a non PowerStig project is suplied' {
                $repository = 'https://github.com/Microsoft/NotPowerStig.git'
                Mock -CommandName Invoke-Git -MockWith { return $repository }
                { Test-PowerStigRepository } | Should throw
            }
        }

        Describe 'Set-GitBranch' -Tag 'tools' {
            $branch = 'dev'

            Context 'Already in dev Branch' {
                Mock -CommandName Get-GitBranch -MockWith { return $branch }
                Mock -CommandName Invoke-Git -MockWith { return } -Verifiable
                It "Should not invoke 'git checkout $branch" {
                    Set-GitBranch -Branch $branch
                    Assert-MockCalled -CommandName Invoke-Git -ParameterFilter { $Command -eq "checkout $Branch" } -Times 0
                }
            }

            Context 'Not already in dev Branch' {
                Mock -CommandName Get-GitBranch -MockWith { return 'master' }
                Mock -CommandName Invoke-Git -MockWith { return } `
                    -ParameterFilter { $Command -eq "checkout $Branch" } -Verifiable
                It "Should invoke 'git checkout $branch" {
                    Set-GitBranch -Branch $branch
                    Assert-MockCalled -CommandName Invoke-Git -Times 1
                }
            }

            Context 'SkipPull' {
                Mock -CommandName Get-GitBranch -MockWith { return $branch }
                Mock -CommandName Invoke-Command -MockWith { return } -Verifiable
                It 'Should not invoke a pull when SkipPull is used' {
                    Set-GitBranch -Branch $branch -SkipPull
                    Assert-MockCalled -CommandName Invoke-Command -ParameterFilter { $ScriptBlock.ToString() -match "git pull" } -Times 0
                }
            }
        }

        Describe 'New-GitReleaseBranch' -Tag 'tools' {
            $branchName = '1.2.3.4-release'

            Mock -CommandName Get-GitBranch -MockWith { return 'master' } -Verifiable
            Mock -CommandName Set-GitBranch -MockWith { } -ParameterFilter { $Branch -eq 'dev'} -Verifiable

            Context 'Branch exists' {
                Mock -CommandName Invoke-Git -MockWith {"[$branchName] Last Commit message"} `
                    -ParameterFilter { $Command -eq "show-branch $branchName"} -Verifiable
                Mock -CommandName Invoke-Git -MockWith {$null} `
                    -ParameterFilter { $Command -eq "checkout $branchName"} -Verifiable

                It "Should switch to the $branchName branch" {
                    New-GitReleaseBranch -BranchName $branchName
                    Assert-VerifiableMock
                }
            }

            Context 'Branch does not exist' {
                Mock -CommandName Invoke-Git -MockWith {"fatal: bad sha1 reference $branchName"} `
                    -ParameterFilter { $Command -eq "show-branch $branchName" } -Verifiable
                Mock -CommandName Invoke-Git -MockWith {$null} `
                    -ParameterFilter { $Command -eq "checkout -b $branchName dev" } -Verifiable

                It "Should create the $branchName branch" {
                    New-GitReleaseBranch -BranchName $branchName
                    Assert-VerifiableMock
                }
            }
        }

        Describe 'Remove-GitReleaseBranch' -Tag 'tools' {
            $branchName = '1.2.3.4-release'
            Mock -CommandName Invoke-Git -MockWith {} `
                -ParameterFilter {$Command -eq "merge $branchName"} -Verifiable
            Mock -CommandName Invoke-Git -MockWith {} `
                -ParameterFilter {$Command -eq "push"} -Verifiable
            Mock -CommandName Invoke-Git -MockWith {} `
                -ParameterFilter {$Command -eq "branch -d $branchName"} -Verifiable
            Mock -CommandName Invoke-Git -MockWith {} `
                -ParameterFilter {$Command -eq "push origin -d $branchName"} -Verifiable
            Mock -CommandName Invoke-Git -MockWith {} `
                -ParameterFilter {$Command -eq "remote prune origin"} -Verifiable
            It "Should remove $branchName from the local and remote repo" {
                Remove-GitReleaseBranch -BranchName $branchName
                Assert-VerifiableMock
            }
        }

        Describe 'Push-GitBranch' -Tag 'tools' {
            $branchName = '1.2.3.4-release'

            Mock -CommandName Invoke-Git -MockWith { return } -ParameterFilter { $Command -eq "push -u origin $BranchName"} -Verifiable

            It "Should NOT Commit or push $branchName if there are no changes" {
                Mock -CommandName Invoke-Git -MockWith { 'Your branch is up to date' } `
                    -ParameterFilter { $Command -eq "commit -a -m $CommitMessage"} -Verifiable
                Push-GitBranch -Name $branchName -CommitMessage 'Commit Message'
                Assert-MockCalled -CommandName Invoke-Git -Times 1
            }

            It "Should Commit or push $branchName if there are no changes" {
                Mock -CommandName Invoke-Git -MockWith { 'Last commit message' } `
                    -ParameterFilter { $Command -eq "commit -a -m $CommitMessage"} -Verifiable
                Push-GitBranch -Name $branchName -CommitMessage 'Commit Message'
                Assert-MockCalled -CommandName Invoke-Git -Times 2
            }
        }

        Describe 'Get-UnreleasedNotes' -Tag 'tools' {
            $sampleReadme = New-Object System.Text.StringBuilder
            $null = $sampleReadme.AppendLine('')
            $null = $sampleReadme.AppendLine('### Unreleased')
            $null = $sampleReadme.AppendLine('')
            $null = $sampleReadme.AppendLine('Update 1')
            $null = $sampleReadme.AppendLine('Update 2')
            $null = $sampleReadme.AppendLine('')
            $null = $sampleReadme.AppendLine('### 1.0.0.0')
            $null = $sampleReadme.AppendLine('')

            Mock -CommandName Get-ChildItem -MockWith { return @{'FullName' = 'empty\path'} }
            Mock -CommandName Get-Content -MockWith { return $sampleReadme.ToString().Split("`n") }

            It 'Should return the unreleased notes trimmed of extra lines' {
                Get-UnreleasedNotes | Should Be ("Update 1`r`r`nUpdate 2" | Out-String).Trim()
            }
        }

        Describe 'Update-Readme' -Tag 'tools' {
            $moduleVersion = '1.2.3.4'
            $sampleReadme  = New-Object System.Text.StringBuilder
            $null = $sampleReadme.AppendLine('')
            $contributors = $null = $sampleReadme.AppendLine('### Contributors').Length
            $null = $sampleReadme.AppendLine('')
            $unreleased = $sampleReadme.AppendLine('### Unreleased').Length
            $null = $sampleReadme.AppendLine('')
            $null = $sampleReadme.AppendLine('Update 1')
            $null = $sampleReadme.AppendLine('Update 2')
            $null = $sampleReadme.AppendLine('')
            $null = $sampleReadme.AppendLine('### 1.0.0.0')
            $null = $sampleReadme.AppendLine('')

            $sampleReadmePath = "$TestDrive\readme.md"
            Mock -CommandName Get-ChildItem -MockWith { @{ FullName = $sampleReadmePath } }
            Mock -CommandName Get-Content -MockWith {$sampleReadme.ToString()}

            Context 'ReleaseNotes' {

                It 'Should correctly add the module version to the readme' {
                    Update-Readme -ModuleVersion $moduleVersion
                    $null = $sampleReadme.Insert($unreleased, "`n### $moduleVersion`n")
                    $readmeContent = Get-Content -Path $sampleReadmePath
                    $readmeContent | Should Be $sampleReadme.ToString()
                }
            }

            Context 'Contributors' {
                $contributorList = @(
                    @{
                        login = 'tester'
                        Name  = 'Test'
                    }
                )
                Mock -CommandName Get-ProjectContributorList -MockWith { $contributorList }
                It 'Should correctly add the contributors to the readme' {
                    Update-Readme -Repository @{}
                    $null = $sampleReadme.Insert($contributors,
                        "`n* [@$($contributorList.login)](https://github.com/$($contributorList.login)) ($($contributorList.Name))`n")
                    $readmeContent = Get-Content -Path $sampleReadmePath
                    $readmeContent | Should Be $sampleReadme.ToString()
                }
            }
        }

        Describe 'Update-Manifest' -Tag 'tools' {
            $moduleVersion = '1.2.3.4'
            $releaseNotes  = 'Added super cool feature'
            $manifestPath  = "$TestDrive\testManifest.psd1"
            New-ModuleManifest -Path $manifestPath -ModuleVersion '1.0.0.0' -ReleaseNotes 'test'
            Update-Manifest -ModuleVersion $moduleVersion -ReleaseNotes $releaseNotes -ManifestPath $manifestPath
            $manifest = Import-PowerShellDataFile -Path $manifestPath

            It 'Should update the manifest version number' {
                $manifest.ModuleVersion | Should Be $moduleVersion
            }
            It 'Should update the manifest release notes' {
                $manifest.PrivateData.PSData.ReleaseNotes | Should Be $releaseNotes
            }
        }

        Describe 'Update-AppVeyorConfiguration' -Tag 'tools' {
            $moduleVersion = '1.2.3.4'
            $versionString = 'version: 0.2.0.{build}'
            $newVersionString = 'version: 1.2.3.{build}'
            $appveyor = New-Object System.Text.StringBuilder
            $null = $appveyor.AppendLine('#---------------------------------#')
            $null = $appveyor.AppendLine('')
            $null = $appveyor.AppendLine($versionString)
            $null = $appveyor.AppendLine('install:')
            $null = $appveyor.AppendLine('  - ps: |')
            $null = $appveyor.AppendLine('    Import-Module "$env:APPVEYOR_BUILD_FOLDER\AppVeyor.psm1"')
            $null = $appveyor.AppendLine('    Invoke-AppveyorInstallTask')
            $null = $appveyor.AppendLine('')
            $null = $appveyor.AppendLine('#---------------------------------#')
            $appveyorPath = "$TestDrive\appveyor.yml"

            Mock -CommandName Get-ChildItem -MockWith { @{ FullName = $appveyorPath } }
            Mock -CommandName Get-Content -MockWith {$appveyor.ToString()}
            $appveyorValue = $appveyor.ToString() -replace [regex]::Escape($versionString), $newVersionString
            Mock -CommandName Set-Content -MockWith {} `
                -ParameterFilter {
                    $path -eq $appveyorPath -and
                    $Value -eq $appveyorValue.TrimEnd()} -Verifiable

            It 'Should update the version number' {
                Update-AppVeyorConfiguration -ModuleVersion $moduleVersion
                Assert-VerifiableMock
            }
        }

        Describe 'Get-ProjectContributorList' -Tag 'tools' {
            $repository = @{
                name = 'PowerStig'
                api_url = 'https://api.github.com'
            }
            $users = @(
                @{
                    user = @{
                        login = 'tester1'
                    }
                },
                @{
                    user = @{
                        login = 'tester2'
                    }
                } | ConvertTo-Json
            )
            Mock -CommandName Invoke-RestMethod -MockWith { return $users | ConvertFrom-Json } `
                -ParameterFilter {$URI -eq "$($repository.api_url)/pulls"}

            Mock -CommandName Invoke-RestMethod -MockWith { return 'testDetails' } `
                -ParameterFilter {$URI -match "$($repository.api_url)/users"}

            $list = Get-ProjectContributorList -Repository $repository
            It 'Should return list if user details' {
                $list[0] | Should Be 'testDetails'
            }
        }

        Describe 'Get-GitHubApiKey' -Tag 'tools' {

            It 'Should load the secure string from disk' {
                Mock -CommandName Split-Path -MockWith { return } -Verifiable
                Mock -CommandName Get-Content -MockWith { 'APIKeyMaterial' } `
                    -ParameterFilter { $path.EndsWith('PowerStigGitHubApi.txt')} -Verifiable
                Mock -CommandName ConvertTo-SecureString -MockWith {} -Verifiable
                Get-GitHubApiKey
                Assert-VerifiableMock
            }

            It 'Should load the file that is passed in' {
                Mock -CommandName Test-Path -MockWith {return $true} -Verifiable
                Mock -CommandName Get-Content -MockWith { 'APIKeyMaterial' } `
                    -ParameterFilter { $path.EndsWith('sampleFile.txt')} -Verifiable
                Mock -CommandName ConvertTo-SecureString -MockWith {} -Verifiable
                Get-GitHubApiKey -SecureFilePath "$Testdrive\sampleFile.txt"
                Assert-VerifiableMock
            }
        }

        Describe 'Get-GitHubRefStatus' -Tag 'tools' {

            $stateList = @('pending', 'failure', 'success')
            $repository = @{}

            foreach ($state in $stateList)
            {
                It "Should return '$state' from rest API" {
                    Mock -CommandName Invoke-RestMethod -MockWith { return @{ state = $state } }
                    $status = Get-GitHubRefStatus -Repository $repository -Name test
                    $status | Should Be $state
                }
            }

            It 'Should throw after waiting 10 minutes for a task to complete' {
                Mock -CommandName Invoke-RestMethod -MockWith { return @{ state = 'pending' } }
                Mock -CommandName Start-Sleep -MockWith { continue } -Verifiable
                { Get-GitHubRefStatus -Repository $repository -Name test -WaitForSuccess } | Should Throw
            }
        }

        Describe 'New-GitHubPullRequest' -Tag 'tools' {
            $moduleVersion = '1.2.3.4'
            $repository = @{
                name = 'PowerStig'
                api_url = 'https://api.github.com'
            }
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ Status = '201 Created' } } `
                -ParameterFilter { $Uri -eq "$($Repository.api_url)/pulls"} -Verifiable
            It 'Should create a PR on GitHub' {
                $response = New-GitHubPullRequest -Repository $repository -ModuleVersion $moduleVersion -BranchHead 'dev'
                $response.Status | Should Be '201 Created'
                Assert-VerifiableMock
            }
        }

        Describe 'Get-GitHubPullRequest' -Tag 'tools' {
            $pullRequestNumber = '34'
            $repository = @{
                name = 'PowerStig'
                api_url = 'https://api.github.com'
            }

            $openPullRequestList = @(
                @{
                    id = '27'
                    head = @{
                        ref = 'new-feature1'
                    }
                    base = @{
                        ref = 'dev'
                    }
                },
                @{
                    id = $pullRequestNumber
                    head = @{
                        ref = 'new-feature2'
                    }
                    base = @{
                        ref = 'master'
                    }
                } #| ConvertTo-Json
            )

            It 'Should return a specifc PR with the correct head and base on GitHub' {
                Mock -CommandName Invoke-RestMethod -MockWith { return $openPullRequestList } `
                    -ParameterFilter { $Uri -eq "$($Repository.api_url)/pulls"} -Verifiable
                $response = Get-GitHubPullRequest -Repository $repository -BranchHead 'new-feature1' -BranchBase 'dev'
                $response.head.ref | Should Be 'new-feature1'
                Assert-VerifiableMock
            }

            It 'Should return a specifc PR number on GitHub' {
                Mock -CommandName Invoke-RestMethod -MockWith { return $openPullRequestList[1] } `
                    -ParameterFilter { $Uri -eq "$($Repository.api_url)/pulls/$pullRequestNumber"} -Verifiable
                $response = Get-GitHubPullRequest -Repository $repository -Number $pullRequestNumber
                $response.id | Should Be $pullRequestNumber
                Assert-VerifiableMock
            }
        }

        Describe 'Approve-GitHubPullRequest' -Tag 'tools' {

            $pullRequest = @{
                name = 'PowerStig'
                url = 'https://api.github.com/pullrequest'
            }
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ merged = $true } } `
                -ParameterFilter { $Uri -eq "$($pullRequest.url)/merge"} -Verifiable
            It 'Should create a PR on GitHub' {
                $response = Approve-GitHubPullRequest -PullRequest $pullRequest -CommitTitle 'Commit Title' -CommitMessage 'Commit Message'
                $response.merged | Should Be $true
                Assert-VerifiableMock
            }
        }

        Describe 'New-GitHubRelease' -Tag 'tools' {
            $repository = @{
                name = 'PowerStig'
                url = 'https://api.github.com/pullrequest'
            }
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ status = '201 Created' } } `
                -ParameterFilter { $Uri -eq "$($repository.api_url)/releases"} -Verifiable
            It 'Should create a release on GitHub' {
                $response = New-GitHubRelease -Repository $repository -TagName '1.2.3.4-PSGallery' -Title 'Release Title' -Description 'Release Notes'
                $response.status | Should Be '201 Created'
                Assert-VerifiableMock
            }
        }

        Describe 'Start-PowerStigRelease' -Tag 'tools' {

            $testGitRepositoryPath = 'c:\dev\project'
            $testModuleVersion = '1.2.3.4'
            $testReleaseBranchName    = "$testModuleVersion-Release"
            $testReleaseNotes  = 'added feature X'
            $repository = @{
                name = 'PowerStig'
                url = 'https://api.github.com'
            }
            $pullRequest = @{
                head = @{
                    sha = 'b8e9aca7e6114734b1710b727786294d0e6a277b'
                }
            }
            Mock -CommandName Push-Location -MockWith { } `
                -ParameterFilter { $GitRepositoryPath -eq $testGitRepositoryPath } -Verifiable
            Mock -CommandName Get-GitBranch -MockWith { 'dev' } -Verifiable
            Mock -CommandName Get-PowerStigRepository -MockWith { return $repository } -Verifiable
            Mock -CommandName Test-ModuleVersion -MockWith { $true } `
                -ParameterFilter { $ModuleVersion -eq $testModuleVersion } -Verifiable
            Mock -CommandName New-GitReleaseBranch -MockWith { } `
                -ParameterFilter { $BranchName -eq $testReleaseBranchName } -Verifiable
            Mock -CommandName Get-UnreleasedNotes -MockWith { return $testReleaseNotes } -Verifiable
            Mock -CommandName Update-Readme -MockWith { } `
                -ParameterFilter { $ModuleVersion -eq $testModuleVersion } -Verifiable
            Mock -CommandName Update-Manifest -MockWith { } `
                -ParameterFilter { $ModuleVersion -eq $testModuleVersion -and $ReleaseNotes -eq $testReleaseNotes } -Verifiable
            Mock -CommandName Update-AppVeyorConfiguration -MockWith { } `
                -ParameterFilter { $ModuleVersion -eq $testModuleVersion } -Verifiable
            Mock -CommandName Push-GitBranch -MockWith { } `
                -ParameterFilter { $Name -eq $testReleaseBranchName } -Verifiable
            Mock -CommandName Get-GitHubApiKey -MockWith { } -Verifiable
            Mock -CommandName Get-GitHubRefStatus -MockWith { 'Success' } `
                -ParameterFilter { $Name -eq $testReleaseBranchName -and $WaitForSuccess -eq $true } -Verifiable
            Mock -CommandName New-GitHubPullRequest -MockWith { return $pullRequest } `
                -ParameterFilter { $BranchHead -eq $testReleaseBranchName } -Verifiable
            Mock -CommandName Get-GitHubRefStatus -MockWith { 'Success' } `
                -ParameterFilter { $Name -eq $pullRequest.head.sha -and $WaitForSuccess -eq $true } -Verifiable

            Context 'New Release' {

                Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion

                It 'Should push to the repo location' {
                    Assert-MockCalled -CommandName Push-Location
                }
                It 'Should get the repo details' {
                    Assert-MockCalled -CommandName Get-PowerStigRepository
                }

                Context 'Module Version' {
                    It 'Should test the module version is greater than currently release' {
                        Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion
                        Assert-MockCalled -CommandName Test-ModuleVersion
                    }
                    It 'Should throw if the module version is not greater than currently release' {
                        Mock -CommandName Test-ModuleVersion -MockWith { $false } `
                            -ParameterFilter { $ModuleVersion -eq $testModuleVersion }
                        {Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion} |
                            Should Throw
                    }
                }
                It 'Should create a new release branch' {
                    Assert-MockCalled -CommandName New-GitReleaseBranch
                }
                Context 'Release Notes' {
                    It 'Should return the release notes' {
                        Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion
                        Assert-MockCalled -CommandName Get-UnreleasedNotes
                    }
                    It 'Should throw if no release notes are found' {
                        Mock -CommandName Get-UnreleasedNotes -MockWith { return '' } -Verifiable
                        {Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion} |
                            Should Throw
                    }
                }
                It 'Should update the readme' {
                    Assert-MockCalled -CommandName Update-Readme
                }
                It 'Should update the module manifest' {
                    Assert-MockCalled -CommandName Update-Manifest
                }
                It 'Should update the AppVeyor yaml' {
                    Assert-MockCalled -CommandName Update-AppVeyorConfiguration
                }
                It 'Should push the release branch to GitHub' {
                    Assert-MockCalled -CommandName Push-GitBranch
                }
                It 'Should get the GitHub api key' {
                    Assert-MockCalled -CommandName Get-GitHubApiKey
                }
                Context 'Release branch build status' {
                    It 'Should check the status of the release build' {
                        Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion
                        Assert-MockCalled -CommandName Get-GitHubRefStatus
                    }
                    It 'Should throw if the release build status is not success' {
                        Mock -CommandName Get-GitHubRefStatus -MockWith { 'Failed' } `
                            -ParameterFilter { $Name -eq $testReleaseBranchName -and $WaitForSuccess -eq $true }
                        {Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion} |
                            Should Throw
                    }
                }
                Context 'Pull request' {
                    It 'Should create a new Pull request' {
                        Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion
                        Assert-MockCalled -CommandName New-GitHubPullRequest
                    }
                    It 'Should check the status of the pull request build' {
                        Assert-MockCalled -CommandName Get-GitHubRefStatus -ParameterFilter { $Name -eq $pullRequest.head.sha -and $WaitForSuccess -eq $true }
                    }
                    It 'Should throw if the pull request build status is not success' {
                        Mock -CommandName Get-GitHubRefStatus -MockWith { 'Failed' } `
                            -ParameterFilter { $Name -eq $pullRequest.head.sha -and $WaitForSuccess -eq $true }
                        {Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion} |
                            Should Throw
                    }
                }
            }

            Context 'Continue Release' {

                Start-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion -Continue

                It 'Should push to the repo location' {
                    Assert-MockCalled -CommandName Push-Location
                }
                It 'Should get the repo details' {
                    Assert-MockCalled -CommandName Get-PowerStigRepository
                }
                It 'Should not test the module version' {
                    Assert-MockCalled -CommandName Test-ModuleVersion -Times 0
                }
                It 'Should not create a new release branch' {
                    Assert-MockCalled -CommandName New-GitReleaseBranch -Times 0
                }
                It 'Should not return the release notes' {
                    Assert-MockCalled -CommandName Get-UnreleasedNotes -Times 0
                }
                It 'Should not update the readme' {
                    Assert-MockCalled -CommandName Update-Readme -Times 0
                }
                It 'Should not update the module manifest' {
                    Assert-MockCalled -CommandName Update-Manifest -Times 0
                }
                It 'Should not update the AppVeyor yaml' {
                    Assert-MockCalled -CommandName Update-AppVeyorConfiguration -Times 0
                }
                It 'Should not push the release branch to GitHub' {
                    Assert-MockCalled -CommandName Push-GitBranch -Times 0
                }
            }
        }

        Describe 'Complete-PowerStigRelease' -Tag 'tools' {
            $testGitRepositoryPath    = 'c:\dev\project'
            $testModuleVersion        = '1.2.3.4'
            $testReleaseBranchName    = "$testModuleVersion-Release"
            $testReleaseNotes         = 'added feature X'
            $powerShellDataFileObject = @{
                PrivateData = @{
                    PSData = @{
                        ReleaseNotes = $testReleaseNotes
                    }
                }
            }
            $repository = @{
                name = 'PowerStig'
                url = 'https://api.github.com'
            }
            $pullRequest = @{
                head = @{
                    sha = 'b8e9aca7e6114734b1710b727786294d0e6a277b'
                }
            }
            $testManifestPath = 'c:\test\path\manifest.psd1'

            Mock -CommandName Push-Location -MockWith { } `
                -ParameterFilter { $GitRepositoryPath -eq $testGitRepositoryPath } -Verifiable
            Mock -CommandName Get-GitBranch -MockWith { 'dev' } -Verifiable
            Mock -CommandName Get-PowerStigRepository -MockWith { return $repository } -Verifiable
            Mock -CommandName Get-GitHubApiKey -MockWith { } -Verifiable
            Mock -CommandName Get-GitHubPullRequest -MockWith { return $pullRequest } `
                -ParameterFilter { $BranchHead -eq $testReleaseBranchName } -Verifiable
            Mock -CommandName Approve-GitHubPullRequest -MockWith { } `
                -ParameterFilter { $PullRequest -eq $PullRequest -and $MergeMethod -eq 'merge' } -Verifiable
            Mock -CommandName Get-ChildItem -MockWith { @{FullName = $testManifestPath } }
            Mock -CommandName Import-PowerShellDataFile -MockWith { return $powerShellDataFileObject } `
                -ParameterFilter { $path -eq $testManifestPath } -Verifiable
            Mock -CommandName New-GitHubRelease -ParameterFilter { $Description -eq $testReleaseNotes } -Verifiable
            Mock -CommandName Remove-GitReleaseBranch -ParameterFilter { $BranchName -eq $testReleaseBranchName} -Verifiable

            Complete-PowerStigRelease -GitRepositoryPath $testGitRepositoryPath -ModuleVersion $testModuleVersion

            It 'Should push to the repo location' {
                Assert-MockCalled -CommandName Push-Location
            }
            It 'Should get the repo details' {
                Assert-MockCalled -CommandName Get-PowerStigRepository
            }
            It 'Should get the GitHub API key' {
                Assert-MockCalled -CommandName Get-GitHubApiKey
            }
            It 'Should get the GitHub release pull request' {
                Assert-MockCalled -CommandName Get-GitHubPullRequest
            }
            It 'Should approve the GitHub release pull request' {
                Assert-MockCalled -CommandName Approve-GitHubPullRequest
            }
            It 'Should Create a new GitHub release' {
                Assert-MockCalled -CommandName New-GitHubRelease
            }
            It 'Should remove the release branch from all repos' {
                Assert-MockCalled -CommandName  Remove-GitReleaseBranch
            }
        }

        Describe 'Complete-PowerStigDevMerge' -Tag 'tools' {
            $testGitRepositoryPath = 'c:\dev\project'
            $testPullRequestNumber = 488
            $repository = @{
                name = 'PowerStig'
                url  = 'https://api.github.com'
            }
            $pullRequest = @{
                head = @{
                    sha = 'b8e9aca7e6114734b1710b727786294d0e6a277b'
                }
            }

            Mock -CommandName Push-Location -MockWith { } `
                -ParameterFilter { $GitRepositoryPath -eq $testGitRepositoryPath } -Verifiable
            Mock -CommandName Get-PowerStigRepository -MockWith { return $repository } -Verifiable
            Mock -CommandName Get-GitHubApiKey -MockWith { } -Verifiable
            Mock -CommandName Get-GitHubPullRequest -MockWith { return $pullRequest } `
                -ParameterFilter { $Number -eq $testPullRequestNumber } -Verifiable
            Mock -CommandName Approve-GitHubPullRequest -MockWith { } `
                -ParameterFilter { $PullRequest -eq $PullRequest -and $MergeMethod -eq 'squash' } -Verifiable
            Mock Set-GitBranch -MockWith {} -ParameterFilter { $Branch -eq 'dev' } -Verifiable
            Mock -CommandName Update-Readme -MockWith { } `
                -ParameterFilter { $Repository -eq $repository } -Verifiable
            Mock -CommandName Push-GitBranch -MockWith { } `
                -ParameterFilter { $Name -eq 'dev' } -Verifiable

            Complete-PowerStigDevMerge -GitRepositoryPath $testGitRepositoryPath -PullRequestNumber $testPullRequestNumber

            It 'Should push to the repo location' {
                Assert-MockCalled -CommandName Push-Location
            }
            It 'Should get the repo details' {
                Assert-MockCalled -CommandName Get-PowerStigRepository
            }
            It 'Should get the GitHub API key' {
                Assert-MockCalled -CommandName Get-GitHubApiKey
            }
            It 'Should get the GitHub release pull request' {
                Assert-MockCalled -CommandName Get-GitHubPullRequest
            }
            It 'Should approve the GitHub release pull request' {
                Assert-MockCalled -CommandName Approve-GitHubPullRequest
            }
            It 'Should switch to the dev branch' {
                Assert-MockCalled -CommandName Set-GitBranch
            }
            It 'Should update the dev branch readme contributors' {
                Assert-MockCalled -CommandName Update-Readme
            }
            It 'Should push the dev branch to GitHub' {
                Assert-MockCalled -CommandName Push-GitBranch
            }
        }

        Describe 'Set-FileHashMarkdown' -Tag 'tools' {
            Mock -CommandName Get-FileHash -MockWith {
                return @{
                    Algorithm = 'SHA256'
                    Hash      = '832A2A0F2EFF192EDB189E577753691143A50B674B14B68961FC08761F1DE81E'
                    Path      = 'c:\dev\project\StigTestFile.xml'
                }
            }

            Mock -CommandName Get-Item -MockWith {
                return @{
                    Mode   = '-a----'
                    Length = 8414
                    Name   = 'StigTestFile.xml'
                }
            }

            It 'Should insert StigTestFile.xml file hash data in FILEHASH.md' {
                $setFileHashMarkdownParams = @{
                    FileHashPath  = 'c:\dev\project\StigTestFile.xml'
                    MarkdownPath  = 'TestDrive:\FILEHASH.md'
                    Algorithm     = 'SHA256'
                    ModuleVersion = '2.0.0.0'
                }

                Set-FileHashMarkdown @setFileHashMarkdownParams
                $fileInfo = Get-ChildItem -Path 'TestDrive:\FILEHASH.md'
                $fileContent = Get-Content -Path 'TestDrive:\FILEHASH.md'
                $shouldBeContent = '| StigTestFile.xml | 832A2A0F2EFF192EDB189E577753691143A50B674B14B68961FC08761F1DE81E | 8414 |'
                $fileInfo.Name | Should Be 'FILEHASH.md'
                $fileContent -contains $shouldBeContent | Should Be $true
            }
        }
    }
}
finally
{

}
