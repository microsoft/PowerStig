
$ruleList = @(
    @{
        testXml = [xml]'<Rule Id="V-1000" severity="low" title="DWORD Test">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>0</ValueData>
        <ValueName>DwordValueName</ValueName>
        <ValueType>Dword</ValueType>
        </Rule>'
        Ensure = 'Present'
        Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft'
        ValueData = '0'
        ValueName = 'DwordValueName'
        ValueType = 'Dword'
    },
    @{
        testXml = [xml]'<Rule id="V-1000" severity="low" title="String">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>O:BAG:BAD:(A;;RC;;;BA)</ValueData>
        <ValueName>StringValueName</ValueName>
        <ValueType>String</ValueType>
        </Rule>'
        Ensure = 'Present'
        Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft'
        ValueData = 'O:BAG:BAD:(A;;RC;;;BA)'
        ValueName = 'StringValueName'
        ValueType = 'String'
    },
    @{
        testXml = [xml]'<Rule id="V-1000" severity="low" title="MultiString Test">
        <Ensure>Present</Ensure>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>123;ABC</ValueData>
        <ValueName>MultiStringValueName</ValueName>
        <ValueType>MultiString</ValueType>
        </Rule>'
        Ensure = 'Present'
        Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft'
        ValueData = @('123', 'ABC')
        ValueName = 'MultiStringValueName'
        ValueType = 'MultiString'
    }
)

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "windows.xRegistry.config.ps1"
. $configFile

Describe 'xRegistry call' {

    foreach ($rule in $ruleList)
    {
        Context "$($rule.ValueType)" {

            It 'Should not throw' {
                function Get-RuleClassData {}
                Mock Get-RuleClassData -MockWith {$rule.testXml.Rule}
                { & xRegistry_config -OutputPath $TestDrive } | Should Not Throw
            }

            $instance = ([Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances("$TestDrive\localhost.mof", 4))[0]

            It 'Should set the correct Ensure flag' {
                $instance.Ensure | Should Be $rule.Ensure
            }
            It 'Should set the correct Key' {
                $instance.Key | Should Be $rule.Key
            }
            It 'Should set the correct Data' {
                $instance.ValueData | Should Be $rule.ValueData
            }
            It 'Should set the correct Name' {
                $instance.ValueName | Should Be $rule.ValueName
            }
            It 'Should set the correct Type' {
                $instance.ValueType | Should Be $rule.ValueType
            }
        }
    }
}
