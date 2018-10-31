#region Header
using module .\..\..\..\Module\Stig.Main\Stig.Main.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

#region Tests

Describe 'Get-NetbiosName' {
    $fqdn = 'server1.test.local'
    $domainParts = @('server1','test','local')
    Mock -CommandName Get-DomainParts -MockWith {$domainParts}

    It "Should return netbios name" {
        Get-NetbiosName -FQDN $fqdn | Should be $domainParts[0]
    }       
}
#endregion