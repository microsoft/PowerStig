#region Header
. $PSScriptRoot\.tests.header.ps1
$setDynamicClassFileParams = @{
    ClassModuleFileName = 'WebAppPoolRule.Convert.psm1'
    PowerStigBuildPath  = $script:moduleRoot
    DestinationPath     = (Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\WebAppPoolRule.Convert.ps1')
}
Set-DynamicClassFile @setDynamicClassFileParams
. $setDynamicClassFileParams.DestinationPath
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Key = 'rapidFailProtection'
                Value = '$true'
                OrganizationValueRequired = $false
                CheckContent = 'Open the IIS 8.5 Manager.

                Click the Application Pools.

                Perform for each Application Pool.

                Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.

                Scroll down to the "Rapid Fail Protection" section and verify the value for "Enabled" is set to "True".

                If the "Rapid Fail Protection:Enabled" is not set to "True", this is a finding.'
            },
            @{
                Key = 'pingingEnabled'
                Value = '$true'
                OrganizationValueRequired = $false
                CheckContent = 'Open the IIS 8.5 Manager.

                Click the Application Pools.

                Perform for each Application Pool.

                Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.

                Scroll down to the "Process Model" section and verify the value for "Ping Enabled" is set to "True".

                If the value for "Ping Enabled" is not set to "True", this is a finding.'
            },
            @{
                Key = 'queueLength'
                Value = ''
                OrganizationValueRequired = $true
                OrganizationValueTestString = '{0} -le 1000'
                CheckContent = 'Open the IIS 8.5 Manager.

                Perform for each Application Pool.

                Click the “Application Pools”.

                Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.

                Scroll down to the "General" section and verify the value for "Queue Length" is set to 1000.

                If the "Queue Length" is set to "1000" or less, this is not a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
