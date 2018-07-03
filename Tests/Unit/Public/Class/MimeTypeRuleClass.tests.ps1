using module ..\..\..\..\Public\Class\MimeTypeRuleClass.psm1
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
#region Test Setup
$rule = [MimeTypeRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$mimeTypeRule = @{
    Ensure       = 'absent'
    Extension    = '.exe'
    RuleCount    = 5
    CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

        Open the IIS 8.5 Manager.
        
        Click on the IIS 8.5 site.
        
        Under IIS, double-click the MIME Types icon.
        
        From the "Group by:" drop-down list, select "Content Type".
        
        From the list of extensions under "Application", verify MIME types for OS shell program extensions have been removed, to include at a minimum, the following extensions:
        
        .exe
        
        If any OS shell MIME types are configured, this is a finding.'
}

$multipleMimeTypeRule = @{
    RuleCount = 5
    CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

        Open the IIS 8.5 Manager.
        
        Click on the IIS 8.5 site.
        
        Under IIS, double-click the MIME Types icon.
        
        From the "Group by:" drop-down list, select "Content Type".
        
        From the list of extensions under "Application", verify MIME types for OS shell program extensions have been removed, to include at a minimum, the following extensions:
        
        .exe
        .dll
        .com
        .bat
        .csh
                
        If any OS shell MIME types are configured, this is a finding.'
}

$mimeTypeMapping = @{
    '.exe' = 'application/octet-stream'
    '.dll' = 'application/x-msdownload'
    '.bat' = 'application/x-bat'
    '.csh' = 'application/x-csh'
    '.com' = 'application/octet-stream'
}

#endregion Test Setup

#region Class Tests
Describe "$ruleClassName Child Class"{
    
    Context 'Base Class'{
        
        It "Shoud have a BaseType of STIG"{
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties'{
        
        $classProperties = @('Ensure', 'Extension', 'MimeType')

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'"{
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods'{
        
        $classMethods = @('SetExtension', 'SetMimeType', 'SetEnsure')

        foreach ( $method in $classMethods )
        {
            It "Should have a method named '$method'"{
                ( $rule | Get-Member -Name $method ).Name | Should Be $method
            }
        }

        # If new methods are added this will catch them so test coverage can be added
        It "Should not have more methods than are tested"{
            $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
            $memberActual = ( $rule | Get-Member -MemberType Method ).Name
            $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
            $compare.Count | Should Be 0
        }
    }
}
#endregion Class Tests

#region Method function Tests
Describe 'Get-Extension'{
    It "Should return $($mimeTypeRule.Extension)"{
        $Extension = Get-Extension -CheckContent ($mimeTypeRule.CheckContent -split '\n').trim()
        $Extension | Should Be $mimeTypeRule.Extension
    } 
}

Describe 'Get-MimeType'{
    foreach ($mimeType in $mimeTypeMapping.GetEnumerator())
    {
        It "Should return $($mimeType.value)"{
            $mimeTypeResult = Get-MimeType -Extension $mimeType.key
            $mimeTypeResult | Should Be $mimeType.value
        }
    }
}

Describe 'Get-Ensure'{
    It "Should return $($mimeTypeRule.Ensure)"{
        $ensure = Get-Ensure -CheckContent ($mimeTypeRule.CheckContent -split '\n')
        $ensure | Should Be $mimeTypeRule.Ensure
    } 
}

Describe 'Test-MultipleMimeTypeRule'{
    It "Should return $true"{
        $multipleRule = Test-MultipleMimeTypeRule -CheckContent ($multipleMimeTypeRule.CheckContent -split '\n').trim()
        $multipleRule | Should Be $true
    } 
}

Describe 'Split-MultipleMimeTypeRule'{
    It "Should return $($multipleMimeTypeRule.RuleCount) rules"{
        $multipleRule = Split-MultipleMimeTypeRule -CheckContent ($multipleMimeTypeRule.CheckContent -split '\n').trim()
        $multipleRule.count | Should Be $multipleMimeTypeRule.RuleCount
    } 
}
#endregion Method function Tests
