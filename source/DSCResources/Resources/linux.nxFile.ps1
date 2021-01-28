# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type nxFileRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    if ($rule.Contents -eq '# Generated via PowerSTIG')
    {
        $rule.Contents = "# Generated via PowerSTIG`n"
    }

    nxFile (Get-ResourceTitle -Rule $rule)
    {
        DestinationPath = $rule.FilePath
        Contents        = $rule.Contents
    }
}
