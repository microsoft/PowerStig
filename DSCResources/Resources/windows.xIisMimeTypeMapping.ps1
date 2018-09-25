# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name MimeTypeRule

foreach ($website in $WebsiteName)
{
    foreach ($rule in $rules)
    {
        xIisMimeTypeMapping "$(Get-ResourceTitle -Rule $rule)-$website"
        {
            ConfigurationPath = "IIS:\Sites\$website"
            Extension         = $rule.Extension
            MimeType          = $rule.MimeType
            Ensure            = $rule.Ensure
        }
    }
}
