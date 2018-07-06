#Requires -Version 5.0
#region Public
<#
    A funny note if you have OCD. The order of the dot sourced files is important due to the way
    that PowerShell processes the files (Top/Down). The Classes in the module depend on the
    enumerations, so if you want to alphabetize this list, don't. PowerShell with throw an error
    indicating that the enumerations can't be found, if you try to load the classes before the
    enumerations.
#>
Import-Module $PSScriptRoot\Private\Main.psm1

. $PSScriptRoot\Public\Function\Convert.PowerStigXml.ps1
. $PSScriptRoot\Public\Function\Convert.Report.ps1
. $PSScriptRoot\Public\Function\Convert.XccdfXml.ps1
#endregion
#region Private
. $PSScriptRoot\Private\Function\Convert.PowerStigXml.ps1
. $PSScriptRoot\Private\Function\Convert.Report.ps1
. $PSScriptRoot\Private\Function\Convert.XccdfXml.ps1
#endregion
Export-ModuleMember -Function @(
    'ConvertFrom-StigXccdf',
    'ConvertTo-DscStigXml',
    'Compare-DscStigXml',
    'Get-ConversionReport',
    'Split-StigXccdf'
)
