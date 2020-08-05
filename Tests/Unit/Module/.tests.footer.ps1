# footer script cleaning up test scripts test data
if ((Get-PSCallStack)[1].Command -notmatch 'Stig\.')
{
    # Cleanup convert module tests
    Remove-Variable STIGSettings -Scope Global
}

$dynamicClassImport = Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport'
if (Test-Path -Path $dynamicClassImport)
{
    Remove-Item -Path $dynamicClassImport -Force -Recurse -Confirm:$false
<<<<<<< HEAD
}
=======
}
>>>>>>> 80bb826bf632f2bdac811990f0e3805c68fcfbad
