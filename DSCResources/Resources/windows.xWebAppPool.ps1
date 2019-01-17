# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $stigData -Name 'WebAppPoolRule'

$stringBuilder = [System.Text.StringBuilder]::new()
foreach ($rule in $rules)
{
    # Strings need to be enclosed in quotes.
    if($rule.Value -match '^\$')
    {
        $value = $rule.Value
    }
    else
    {
        $value = "'$($rule.Value)'"
    }

    $null = $stringBuilder.AppendLine("$($rule.Key) = $value")
}

foreach ($appPool in $WebAppPool)
{
    $resourceTitle = "[$($rules.id -join ' ')]$appPool"
    $scriptBlock = [scriptblock]::Create("
        xWebAppPool '$resourceTitle'
        {
            Name = '$appPool'
            $($stringBuilder.ToString())
        }"
    )

    & $scriptBlock
}
