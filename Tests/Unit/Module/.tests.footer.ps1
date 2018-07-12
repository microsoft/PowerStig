
if ((Get-PSCallStack)[1].Command -notmatch 'Stig\.')
{
    # Cleanup convert module tests
    Remove-Variable STIGSettings -Scope Global
}
else
{
    # Cleanup Stig module tests
}
