# Unit Test Header
$script:DSCModuleName            = 'PowerStig'
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent ( Split-Path -Parent $PSScriptRoot ) )
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'Tests\helper.psm1') -Force
