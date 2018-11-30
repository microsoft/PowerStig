# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $stigData -Name IisLoggingRule

if ($rules)
{
    $logFlags = Get-UniqueStringArray -InputObject $rules.LogFlags -AsString
    $logFormat = Get-UniqueString -InputObject $rules.LogFormat
    $logPeriod = Get-UniqueString -InputObject $rules.LogPeriod
    $logCustomField = Get-LogCustomField -LogCustomField $rules.LogCustomFieldEntry.Entry -Resource 'xWebSite'

    foreach ($website in $WebsiteName)
    {
        $resourceTitle = "[$($rules.id -join ' ')]$website"
        
        if ($null -eq $logPeriod)
        {
            $scriptBlock = [scriptblock]::Create("
                xWebSite '$resourceTitle'
                {
                    Name            = '$website'
                    LogFlags        = @($logFlags)
                    LogFormat       = '$logFormat'
                    LogCustomFields = @($logCustomField)
                }"
            )
        }
        else
        {
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
        }
        
        & $scriptBlock
    }
}
