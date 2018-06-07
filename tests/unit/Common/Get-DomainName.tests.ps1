[string] $sut = $MyInvocation.MyCommand.Path -replace '\\tests\\','\src\' `
-replace '\.tests\.ps1','.ps1' `
-replace '\\unit\\','\'

Import-Module $sut -Force

Describe 'Get-DomainName' {

    Context 'Domain Name' {

        It 'Should return the FQDN of the host domain name if one is not povided.' {
            Mock -CommandName Get-DomainFQDN -MockWith {return 'Contoso.com'}
            Get-DomainName -DomainName $null | Should Be 'Contoso.com'
        }
    
        It 'Should return the FQDN by default.' {
            Get-DomainName -DomainName 'Contoso.com' | Should Be 'Contoso.com'
        }
    
        It 'Should return the FQDN name of the FQDN that is provided.' {
            Get-DomainName -DomainName 'Contoso.com' -Format 'FQDN' | Should Be 'Contoso.com'
        }
    
        It 'Should return the netbios name of the FQDN that is provided.' {
            Get-DomainName -DomainName 'Contoso.com' -Format 'NetbiosName' | Should Be 'Contoso'
        }
    
        It 'Should return the distinguished name of the FQDN that is provided.' {
            Get-DomainName -DomainName 'Contoso.com' -Format 'DistinguishedName' | Should Be 'DC=Contoso,DC=com'
        }
    }

    Context 'Forest Name' {

        It 'Should return the FQDN of the host root domain name if one is not povided.' {
            Mock -CommandName Get-ForestFQDN -MockWith {'forest.root'}
            Get-DomainName -ForestName $null | Should Be 'forest.root'
        }
    
        It 'Should return the FQDN by default.' {
            Get-DomainName -ForestName 'Contoso.com' | Should Be 'Contoso.com'
        }
    
        It 'Should return the FQDN name of the FQDN that is provided.' {
            Get-DomainName -ForestName 'Contoso.com' -Format 'FQDN' | Should Be 'Contoso.com'
        }
    
        It 'Should return the netbios name of the FQDN that is provided.' {
            Get-DomainName -ForestName 'Contoso.com' -Format 'NetbiosName' | Should Be 'Contoso'
        }
    
        It 'Should return the distinguished name of the FQDN that is provided.' {
            Get-DomainName -ForestName 'Contoso.com' -Format 'DistinguishedName' | Should Be 'DC=Contoso,DC=com'
        }
    }
}

Describe 'Get-NetbiosName' {

    It 'Should return the Netbios Name from a fqdn' {
        Get-NetbiosName -FQDN 'Contoso.com' | Should Be 'Contoso'
    }

    It 'Should return the Netbios Name from a short name' {
        Get-NetbiosName -FQDN 'Contoso' | Should Be 'Contoso'
    }

    It 'Should return the Netbios Name from a child domain fqdn ' {
        Get-NetbiosName -FQDN 'Child.Contoso.com' | Should Be 'Child'
    }
}

Describe 'Get-DistinguishedName' {

    It 'Should return a Distinguished Name' {
        Get-DistinguishedName -FQDN 'Contoso.com' | Should Be 'DC=Contoso,DC=com'
    }

    It 'Should return a Distinguished Name' {
        Get-DistinguishedName -FQDN 'Contoso' | Should Be 'DC=Contoso'
    }
}

Describe 'Format-DistinguishedName' {

    It 'Should join array into an DN' {
        Format-DistinguishedName -Parts @('child','test','com')  | Should Be 'dc=child,dc=test,dc=com'
    }
}
Describe 'Get-DomainParts' {

    It 'Should split the fqdn into an array' {
        Get-DomainParts -FQDN 'child.test.com' | Should Be @('child','test','com')
    }
}
