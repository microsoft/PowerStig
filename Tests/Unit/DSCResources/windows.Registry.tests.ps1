$ruleList = @(
    @{
        testXml   = [xml]'<Rule Id="V-1000" severity="low" title="Registry - DWORD Test" dscresource="Registry">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>0</ValueData>
        <ValueName>DwordValueName</ValueName>
        <ValueType>Dword</ValueType>
        </Rule>'
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft'
        ValueData = '0'
        ValueName = 'DwordValueName'
        ValueType = 'Dword'
        title     = 'Registry - DWORD Test'
    },
    @{
        testXml   = [xml]'<Rule id="V-1000" severity="low" title="Registry - String" dscresource="Registry">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>O:BAG:BAD:(A;;RC;;;BA)</ValueData>
        <ValueName>StringValueName</ValueName>
        <ValueType>String</ValueType>
        </Rule>'
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft'
        ValueData = 'O:BAG:BAD:(A;;RC;;;BA)'
        ValueName = 'StringValueName'
        ValueType = 'String'
        title     = 'Registry - String'
    },
    @{
        testXml   = [xml]'<Rule id="V-1000" severity="low" title="Registry - MultiString Test" dscresource="Registry">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>123;ABC</ValueData>
        <ValueName>MultiStringValueName</ValueName>
        <ValueType>MultiString</ValueType>
        </Rule>'
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft'
        ValueData = @('123', 'ABC')
        ValueName = 'MultiStringValueName'
        ValueType = 'MultiString'
        title     = 'Registry - MultiString Test'
    },
    @{
        testXml   = [xml]'<Rule id="V-1000" severity="low" title="Registry - Empty MultiString Test" dscresource="Registry">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>
        </ValueData>
        <ValueName>MultiStringValueName</ValueName>
        <ValueType>MultiString</ValueType>
      </Rule>'
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft'
        ValueData = ''
        ValueName = 'MultiStringValueName'
        ValueType = 'MultiString'
        title     = 'Registry - Empty MultiString Test'
    },
    @{
        testXml = [xml]'<Rule id="V-1000" severity="low" title="Registry - Null Value MultiString Test" dscresource="Registry">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>
        </ValueData>
        <ValueName>MultiStringValueName</ValueName>
        <ValueType>MultiString</ValueType>
      </Rule>'
      Ensure = 'Present'
      Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft'
      ValueData = $null
      ValueName = 'MultiStringValueName'
      ValueType = 'MultiString'
      title     = 'Registry - Null Value MultiString Test'
    },
    @{
        testXml   = [xml]'<Rule id="V-1000" severity="low" title="Registry - Absent value Test" dscresource="Registry">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>ShouldBeAbsent</ValueData>
        <ValueName>OptionalAbsent</ValueName>
        <ValueType>Dword</ValueType>
      </Rule>'
        Ensure    = 'Absent'
        Key       = 'HKLM:\SOFTWARE\Policies\Microsoft'
        ValueData = $null
        ValueName = 'OptionalAbsent'
        ValueType = 'Dword'
        title     = 'Registry - Absent value Test'
    },
    @{
        testXml   = [xml]'<Rule Id="V-1000" severity="low" title="DWORD Test" dscresource="RegistryPolicyFile">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>0</ValueData>
        <ValueName>DwordValueName</ValueName>
        <ValueType>Dword</ValueType>
        </Rule>'
        Ensure    = 'Present'
        Key       = 'SOFTWARE\Policies\Microsoft'
        ValueData = '0'
        ValueName = 'DwordValueName'
        ValueType = 'Dword'
        title     = 'RegistryPolicyFile - DWORD Test'
    },
    @{
        testXml   = [xml]'<Rule id="V-1000" severity="low" title="RegistryPolicyFile - String" dscresource="RegistryPolicyFile">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>O:BAG:BAD:(A;;RC;;;BA)</ValueData>
        <ValueName>StringValueName</ValueName>
        <ValueType>String</ValueType>
        </Rule>'
        Ensure    = 'Present'
        Key       = 'SOFTWARE\Policies\Microsoft'
        ValueData = 'O:BAG:BAD:(A;;RC;;;BA)'
        ValueName = 'StringValueName'
        ValueType = 'String'
        title     = 'RegistryPolicyFile - String'
    },
    @{
        testXml   = [xml]'<Rule id="V-1000" severity="low" title="RegistryPolicyFile - MultiString Test" dscresource="RegistryPolicyFile">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>123;ABC</ValueData>
        <ValueName>MultiStringValueName</ValueName>
        <ValueType>MultiString</ValueType>
        </Rule>'
        Ensure    = 'Present'
        Key       = 'SOFTWARE\Policies\Microsoft'
        ValueData = @('123', 'ABC')
        ValueName = 'MultiStringValueName'
        ValueType = 'MultiString'
        title     = 'RegistryPolicyFile - MultiString Test'
    },
    @{
        testXml   = [xml]'<Rule id="V-1000" severity="low" title="RegistryPolicyFile - Empty MultiString Test" dscresource="RegistryPolicyFile">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>
        </ValueData>
        <ValueName>MultiStringValueName</ValueName>
        <ValueType>MultiString</ValueType>
      </Rule>'
        Ensure    = 'Present'
        Key       = 'SOFTWARE\Policies\Microsoft'
        ValueData = ''
        ValueName = 'MultiStringValueName'
        ValueType = 'MultiString'
        title     = 'RegistryPolicyFile - Empty MultiString Test'
    },
    @{
        testXml = [xml]'<Rule id="V-1000" severity="low" title="RegistryPolicyFile - Null Value MultiString Test" dscresource="RegistryPolicyFile">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>
        </ValueData>
        <ValueName>MultiStringValueName</ValueName>
        <ValueType>MultiString</ValueType>
      </Rule>'
      Ensure = 'Present'
      Key = 'SOFTWARE\Policies\Microsoft'
      ValueData = $null
      ValueName = 'MultiStringValueName'
      ValueType = 'MultiString'
      title     = 'RegistryPolicyFile - Null Value MultiString Test'
    },
    @{
        testXml   = [xml]'<Rule id="V-1000" severity="low" title="RegistryPolicyFile - Absent value Test" dscresource="RegistryPolicyFile">
        <Ensure>Absent</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>ValueDataAbsent</ValueData>
        <ValueName>OptionalAbsent</ValueName>
        <ValueType>Dword</ValueType>
      </Rule>'
        Ensure    = 'Absent'
        Key       = 'SOFTWARE\Policies\Microsoft'
        ValueData = 'ValueDataAbsent'
        ValueName = 'OptionalAbsent'
        ValueType = 'Dword'
        title     = 'RegistryPolicyFile - Absent value Test'
    }
)

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "windows.Registry.config.ps1"
. $configFile

Describe 'Registry call' {

    foreach ($rule in $ruleList)
    {
        Context "$($rule.title)" {

            It 'Should not throw' {
                function Select-Rule {}
                Mock Select-Rule -MockWith {$rule.testXml.Rule}
                { & Registry_config -OutputPath $TestDrive } | Should Not Throw
            }

            $instance = ([Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances("$TestDrive\localhost.mof", 4))[0]

            It 'Should set the correct Ensure flag' {
                $instance.Ensure | Should Be $rule.Ensure
            }
            It 'Should set the correct Key' {
                $instance.Key | Should Be $rule.Key
            }

            It 'Should set the correct Name' {
                $instance.ValueName | Should Be $rule.ValueName
            }
            if ($instance.Ensure -eq 'Present' -or $instance.ResourceID -match '\[RegistryPolicyFile\]')
            {
                It 'Should set the correct Type' {
                    $instance.ValueType | Should Be $rule.ValueType
                }
                It 'Should set the correct Data' {
                    if ($null -eq $rule.ValueData)
                    {
                        $instance.ValueData | Should Be $([string]::Empty)
                    }
                    else
                    {
                        $instance.ValueData | Should Be $rule.ValueData
                    }
                }
            }
            else
            {
                It 'Should set the correct Type' {
                    $instance.ValueType | Should Be $null
                }
                It 'Should set the correct Data' {
                    $instance.ValueData | Should Be $null
                }
            }

        }
    }
}
