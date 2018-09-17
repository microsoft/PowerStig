#region Header
$rules = Get-RuleClassData -StigData $StigData -Name WebAppPoolRule
#endregion Header
#region Resource

$stringBuilder = [System.Text.StringBuilder]::new()
foreach($rule in $rules)
{
    $null = $stringBuilder.AppendLine("$($rule.key) = $($rule.value)")
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
#endregion Resource
