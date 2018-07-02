using module .\..\..\..\Public\Class\Technology.psm1

$testValidateSet = @('Windows','SQL')

$invalidName = 'Cheeseburger'


Describe "Technology Class" {
    Context "Constructor" {
        foreach ($technology in $TestValidateSet)
        {
            It "Should create an Technology class instance using $technology data" {
                $newTechnology = [Technology]::new($technology)
                $newTechnology.Name | Should Be $technology
            }
        }

        It "Should throw an exception for Technology not being available: " {
            { [Technology]::new($InvalidName) } | Should Throw
        }
    }

    Context "Static Properties" {
        It "ValidateSet: Should match TestValidateSet to static ValidateSet property" {
            $ValidateSet = [Technology]::ValidateSet
            foreach ($Tech in $ValidateSet) 
            {
                $match = $TestValidateSet.Where({$_ -eq $Tech})
                $match | Should Be $Tech
            }
        }
    }

    Context "Instance Methods" {

        foreach ($technology in $TestValidateSet)
        {
            It "Validate: Should be able to validate $technology TechnologyRole. Valid property config." {
                $newTechnology = [Technology]::new()
                $newTechnology.Name = $technology
                $newTechnology.Validate() | Should Be $true
            }
        }

        It "Validate: Should be able to validate $technology TechnologyRole. Invalid property config." {
            $technology = [Technology]::new()
            $technology.Name = $InvalidName
            $technology.Validate() | Should Be $false
        }
    }

    Context "Static Methods" {
        It "Available: Should be able to return available technologies" {
            $validateSet = [Technology]::ValidateSet
            $available = [Technology]::Available()

            $available | Should Be $validateSet
        }
    }
}
