#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$domainName = 'Domain.test'
$forestName = 'Forest.test'
$domainDistinguished = "DC={0},DC={1}" -f $domainName.Split(".")
$forestDistinguished = "DC={0},DC={1}" -f $forestName.Split(".")
$domainDistinguishedPart1 = "DC=Domain"
$domainDistinguishedPart2 = "DC=Domain,DC=Test"
$parts = @("Domain","Test")

Describe 'Get-DomainName' {
        # Test parameter validity -OutputPath
        It 'Should return Domain FQDN' {
            Get-DomainName -DomainName $DomainName -Format 'FQDN' | Should -Match $domainName
        }

        It 'Should return Forest FQDN' {
            Get-DomainName -ForestName $ForestName  -Format 'FQDN' | Should -Match $forestName
        }

        It 'Should return Domain NetbiosName' {
            Get-DomainName -DomainName $DomainName -Format 'NetbiosName' | Should -Match ($domainName.Split("."))[0]
        }

        It 'Should return Forest NetbiosName' {
            Get-DomainName -ForestName $ForestName  -Format 'NetbiosName' | Should -Match ($forestName.Split("."))[0]
        }

        It 'Should return Domain DistinguishedName' {
            Get-DomainName -DomainName $DomainName -Format 'DistinguishedName' | Should Match $domainDistinguished
        }

        It 'Should return Forest DistinguishedName' {
            Get-DomainName -ForestName $ForestName  -Format 'DistinguishedName' | Should Match $forestDistinguished
        }
}

Describe 'Get-DomainFQDN' {
    # Test parameter validity -OutputPath
    It 'Should return $env:USERDNSDOMAIN' {
        Get-DomainFQDN | Should -Match $env:USERDNSDOMAIN
    }
}

Describe 'Get-ForestFQDN' {
    # Test parameter validity -OutputPath
    It 'Should return $null' {
        Get-ForestFQDN | Should BeNullOrEmpty
    }
}

Describe 'Get-NetbiosName' {
    # Test parameter validity -OutputPath
    It 'Should test 2 parts and return Domain' {
        Get-NetbiosName -FQDN $DomainName | Should -Match ($DomainName.Split("."))[0]
    }

    It 'Should test 1 part and return Domain' {
        Get-NetbiosName -FQDN "Domain" | Should -Match ($DomainName.Split("."))[0]
    }
}

Describe 'Get-DistinguishedName' {
    # Test parameter validity -OutputPath
    It 'Should test 1 part and return "DC=Domain"' {
        Get-DistinguishedName -FQDN "Domain" | Should -Match $domainDistinguishedPart1
    }

    It 'Should test 2 parts and return "DC=Domain,DC=Test"' {
        Get-DistinguishedName -FQDN $DomainName | Should -Match $domainDistinguishedPart2
    }
}

Describe 'Format-DistinguishedName' {
    # Test parameter validity -OutputPath
    It 'Should test 2 parts and return "DC=Domain"' {
        Format-DistinguishedName -Parts "Domain" | Should -Match $domainDistinguishedPart1
    }

    It 'Should test 1 part and return "DC=Domain,DC=Test"' {
        Format-DistinguishedName -Parts $parts | Should -Match $domainDistinguishedPart2
    }
}

Describe 'Get-DomainParts' {
    # Test parameter validity -OutputPath
    It 'Should split the FQDN' {
        Get-DomainParts -FQDN $domainName | Should -eq $parts
    }
}
