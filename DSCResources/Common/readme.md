# File names

The file naming convention in this directory indicate the target platform and sub-component DSC resource.
Many of the STIG's define registry settings so it will be reused the most, but all resources are setup and implemented in the same manner.

For example 'windows.registry.ps1' indicates that is contains the DSC resource to manage the registry on the windows platform.

Any composite resource in the PowerStigDsc module can dot source this file without having to do any additional work.
