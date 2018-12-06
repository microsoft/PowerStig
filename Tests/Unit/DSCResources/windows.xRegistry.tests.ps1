
$testDataRules = @(
    @{
        testXml = [xml]'<Rule Id="V-1000" severity="low" title="DWORD Test">
        <Ensure>Present</Ensure>
        <IsNullOrEmpty>False</IsNullOrEmpty>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>0</ValueData>
        <ValueName>DwordValueName</ValueName>
        <ValueType>Dword</ValueType>
        </Rule>'
        ValueName = 'DwordValueName'
        ValueData = '0'
        ValueType = 'Dword'
    },
    @{
        testXml = [xml]'<Rule id="V-1000" severity="low" title="MultiString Test">
        <Ensure>Present</Ensure>
        <IsNullOrEmpty>False</IsNullOrEmpty>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>123;ABC</ValueData>
        <ValueName>MultiStringValueName</ValueName>
        <ValueType>MultiString</ValueType>
      </Rule>'
        ValueName = 'MultiStringValueName'
        ValueData = @('123', 'ABC')
        ValueType = 'MultiString'
    },
    @{
        testXml = [xml]'<Rule id="V-1000" severity="low" title="String">
        <Ensure>Present</Ensure>
        <IsNullOrEmpty>False</IsNullOrEmpty>
        <Key>HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft</Key>
        <ValueData>O:BAG:BAD:(A;;RC;;;BA)</ValueData>
        <ValueName>StringValueName</ValueName>
        <ValueType>String</ValueType>
        </Rule>'
        ValueName = 'StringValueName'
        ValueData = 'O:BAG:BAD:(A;;RC;;;BA)'
        ValueType = 'String'
    }
)

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "windows.xRegistry.config.ps1"
. $configFile

Describe 'xRegistry call' {

    foreach ($testData in $testDataRules)
    {
        Context "$($testData.ValueType)" {

            . $configFile
            function Get-RuleClassData {}
            Mock Get-RuleClassData -MockWith {$testData.testXml.Rule}

            It 'Should not throw' {
                { & xRegistry_config -OutputPath $TestDrive } | Should Not Throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instance = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            It 'Should set the correct Type' {
                $instance[0].ValueType | Should Be $testData.ValueType
            }

            It 'Should set the correct Data' {
                $instance[0].ValueData | Should Be $testData.ValueData
            }
        }
    }
}
