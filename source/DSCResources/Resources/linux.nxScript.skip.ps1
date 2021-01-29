# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SkippedRule

foreach ($rule in $rules)
{
    $resourceTitle = Get-ResourceTitle -Rule $rule

    nxScript $resourceTitle
    {
        # Using the GetScript to reflect the resource information if called.
        GetScript = "#!/bin/bash`necho $resourceTitle"

        # Must return a $true value. The skip rules will be included in the mof but no action is taken
        TestScript = "#!/bin/bash`nexit 0"

        <#
            This is left blank because we are only using the script resource as an audit tool for
            STIG items that should be part of an orchestration function and not configuration.
        #>
        SetScript = '#!/bin/bash'
    }
}
