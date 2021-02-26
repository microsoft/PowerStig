# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type nxFileLineRule -RuleList $stig.RuleList

$audispRemoteConfCreated = $false
$auRemoteConfCreated = $false

foreach ($rule in $rules)
{
    <#
        There are 8 rules that require audisp-remote.conf and audisp-remote.conf, which do not exist by default.
        In order to successfully apply these rules the file will need to be created. Unfortunately the file cannot
        be created if it does not exist with nxFileLine, instead, the current automation will hard code the file creation
        using nxFile when the FilePath for those files is detected.
    #>
    if ($rule.FilePath -eq '/etc/audisp/audisp-remote.conf' -and -not $audispRemoteConfCreated)
    {
        nxFile (Get-ResourceTitle -Rule $rule)
        {
            DestinationPath = '/etc/audisp/audisp-remote.conf'
            Contents        = "# Generated via PowerSTIG`n"
        }

        $audispRemoteConfCreated = $true
    }

    if ($rule.FilePath -eq '/etc/audisp/plugins.d/au-remote.conf' -and -not $auRemoteConfCreated)
    {
        nxFile (Get-ResourceTitle -Rule $rule)
        {
            DestinationPath = '/etc/audisp/plugins.d/au-remote.conf'
            Contents        = "# Generated via PowerSTIG`n"
        }

        $auRemoteConfCreated = $true
    }

    if ($rule.DoesNotContainPattern -ne 'PatternNotRequired')
    {
        nxFileLine (Get-ResourceTitle -Rule $rule)
        {
            FilePath              = $rule.FilePath
            ContainsLine          = $rule.ContainsLine
            DoesNotContainPattern = $rule.DoesNotContainPattern
        }
    }
    else
    {
        nxFileLine (Get-ResourceTitle -Rule $rule)
        {
            FilePath     = $rule.FilePath
            ContainsLine = $rule.ContainsLine
        }
    }
}
