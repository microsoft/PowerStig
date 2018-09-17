#region Header
$rules = Get-RuleClassData -StigData $StigData -Name IisLoggingRule
#endregion Header
#region Resource

$logFlags = Get-UniqueStringArray -InputObject $rules.LogFlags -AsString
$logFormat = Get-UniqueString -InputObject $rules.LogFormat
$logPeriod = Get-UniqueString -InputObject $rules.LogPeriod
$logCustomField = Get-LogCustomField -LogCustomField $rules.LogCustomFieldEntry.Entry

foreach ($website in $WebsiteName)
{
    $resourceTitle = "[$($rules.id -join ' ')]$website"

    $scriptBlock = [scriptblock]::Create("
        xWebSite '$resourceTitle'
        {
            Name            = '$website'
            LogFlags        = @($logFlags)
            LogFormat       = '$logFormat'
            LogPeriod       = '$logPeriod'
            LogCustomFields = @($logCustomField)
        }"
    )

    & $scriptBlock
}
#endregion Resource
