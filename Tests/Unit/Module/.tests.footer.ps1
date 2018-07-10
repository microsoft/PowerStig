
<#
    Always unload the module once the tests complete or fail 
    $script:moduleNamecomes from the .test.Header.ps1 file 
    and is derived from the file name
#>
Remove-Module $script:moduleName
Remove-Variable STIGSettings -Scope Global
