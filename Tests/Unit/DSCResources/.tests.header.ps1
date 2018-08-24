# Unit Test Header
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent ( Split-Path -Parent $PSScriptRoot ) )
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1') -Force
