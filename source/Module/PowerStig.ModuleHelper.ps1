#This script was created to get around a cyclic redundancy error that is present in PowerShell 5.
#When importing PowerSTIG with the following modules listed as required modules in the manifest the error occurs
#Link to the issue - https://github.com/PowerShell/PowerShell/issues/2607

$requiredmodules = @(
    @{ModuleName = 'VMware.VimAutomation.Sdk'; ModuleVersion = '12.0.0.15939651'}
    @{ModuleName = 'VMware.VimAutomation.Common'; ModuleVersion = '12.0.0.15939652'}
    @{ModuleName = 'VMware.Vim'; ModuleVersion ='7.0.0.15939650'}
    @{ModuleName = 'VMware.VimAutomation.Cis.Core'; ModuleVersion = '12.0.0.15939657'}
    @{ModuleName = 'VMware.VimAutomation.Core'; ModuleVersion = '12.0.0.15939655'}
    @{ModuleName = 'VMware.VimAutomation.Storage'; ModuleVersion = '12.0.0.15939648'}
    @{ModuleName = 'VMware.VimAutomation.Vds'; ModuleVersion = '12.0.0.15940185'}
    @{ModuleName = 'Vmware.vSphereDsc'; ModuleVersion = '2.1.0.58'}
)

foreach($module in $requiredmodules)
{
    if(Get-Module -ListAvailable -Name $module.ModuleName)
    {
        import-module -Name $module.ModuleName -version $module.ModuleVersion -ErrorAction Stop
    }
    else
    {
        Write-Error -Message "$($module.ModuleName) Version: $($module.ModuleVersion) is not installed, please install and try again."
        break
    }
}
