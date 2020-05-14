<#
    This script was created to get around a cyclic redundancy error that is present in PowerShell 5.
    When importing PowerSTIG with the following modules listed as required modules in the manifest the error occurs
    Link to the issue - https://github.com/PowerShell/PowerShell/issues/2607
#>
$requiredModules = @{
    'VMware.VimAutomation.Sdk' = '12.0.0.15939651'
    'VMware.VimAutomation.Common' = '12.0.0.15939652'
    'VMware.Vim' = '7.0.0.15939650'
    'VMware.VimAutomation.Cis.Core' = '12.0.0.15939657'
    'VMware.VimAutomation.Core' = '12.0.0.15939655'
    'VMware.VimAutomation.Storage' = '12.0.0.15939648'
    'VMware.VimAutomation.Vds' = '12.0.0.15940185'
    'Vmware.vSphereDsc' = '2.1.0.58'
}
try
{
    foreach ($moduleName in $requiredModules.Keys)
    {
        $script:importModuleParams = @{
            Name = $moduleName
            Version = $requiredModules[$moduleName]
            ErrorAction = 'Stop'
        }
        if (Get-Module -ListAvailable -Name $importModuleParams.Name)
        {
            Import-Module @importModuleParams
        }
    }
}
catch
{
    Write-Error -Message "$($importModuleParams.Name) Version: $($importModuleParams.Version) is not installed, please install and try again."
}
