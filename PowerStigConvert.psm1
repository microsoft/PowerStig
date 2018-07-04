#Requires -Version 5.0
#region Public
<#
    A funny note if you have OCD. The order of the dot sourced files is important due to the way
    that PowerShell processes the files (Top/Down). The Classes in the moduel depend on the
    enumerations, so if you want to alphabetize this list, don't. PowerShell with throw an error
    indicating that the enumerations can't be found, if you try to load the classes before the
    enumerations.
#>
Import-Module $PSScriptRoot\Private\Main.psm1

. $PSScriptRoot\Public\Functions\Convert.PowerStigXml.ps1
. $PSScriptRoot\Public\Functions\Convert.Report.ps1
. $PSScriptRoot\Public\Functions\Convert.XccdfXml.ps1
#endregion
# Region Private
. $PSScriptRoot\Private\Functions\Convert.PowerStigXml.ps1
. $PSScriptRoot\Private\Functions\Convert.Report.ps1
. $PSScriptRoot\Private\Functions\Convert.XccdfXml.ps1
#endregion
Export-ModuleMember -Function @(
    'ConvertFrom-StigXccdf',
    'ConvertTo-DscStigXml',
    'Compare-DscStigXml',
    'Get-ConversionReport',
    'Split-StigXccdf'
)
