
$testDataRules = @(
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
    }
)

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "windows.xRegistry.config.ps1"
. $configFile

Describe 'xRegistry call' {

    foreach ($testData in $testDataRules)
    {
        Context "$($testData.ValueType)" {

            function Get-RuleClassData {}
            Mock Get-RuleClassData -MockWith {$testData.testXml.Rule}

            It 'Should not throw' {
                { & xRegistry_config -OutputPath $TestDrive } | Should Not Throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instance = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            It 'Should set the correct Ensure flag' {
                $instance[0].Ensure | Should Be $testData.Ensure
            }
            It 'Should set the correct Key' {
                $instance[0].Key | Should Be $testData.Key
            }
            It 'Should set the correct Data' {
                $instance[0].ValueData | Should Be $testData.ValueData
            }
            It 'Should set the correct Name' {
                $instance[0].ValueName | Should Be $testData.ValueName
            }
            It 'Should set the correct Type' {
                $instance[0].ValueType | Should Be $testData.ValueType
            }
        }
    }
}
