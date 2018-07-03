#region Header V1
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\Common.Enum.psm1
using module .\Convert.Stig.psm1
using module .\..\Data\Convert.Main.psm1
# Additional required modules

#endregion
#region Class Definition
Class UserRightRule : STIG
{
    [ValidateNotNullOrEmpty()] [string] $DisplayName
    [ValidateNotNullOrEmpty()] [string] $Constant
    [ValidateNotNullOrEmpty()] [string] $Identity
    [bool] $Force = $false

    # Constructor
    UserRightRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetDisplayName ()
    {
        $thisDisplayName = Get-UserRightDisplayName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDisplayName ) )
        {
            $this.set_DisplayName( $thisDisplayName )
        }
    }

    [void] SetConstant ()
    {
        $thisConstant = Get-UserRightConstant -UserRightDisplayName $this.DisplayName

        if ( -not $this.SetStatus( $thisConstant ) )
        {
            $this.set_Constant( $thisConstant )
        }
    }

    [void] SetIdentity ()
    {
        $thisIdentity = Get-UserRightIdentity -CheckContent $this.SplitCheckContent
        $return = $true
        if ( [String]::IsNullOrEmpty( $thisIdentity ) )
        {
            $return = $false
        }
        elseif ( $thisIdentity -ne 'NULL' )
        {
            if ($thisIdentity -join "," -match "{Hyper-V}")
            {
                $this.SetOrganizationValueRequired()
                $HyperVIdentity = $thisIdentity -join "," -replace "{Hyper-V}", "NT Virtual Machine\\Virtual Machines"
                $NoHyperVIdentity = $thisIdentity.Where( {$_ -ne "{Hyper-V}"}) -join ","
                $this.set_OrganizationValueTestString("'{0}' -match '^($HyperVIdentity|$NoHyperVIdentity)$'")
            }
        }

        # add the results reguardless so they are easier to update
        $this.Identity = $thisIdentity -Join ","
        #return $return
    }

    [void] SetForce ()
    {
        if ( Test-SetForceFlag -CheckContent $this.SplitCheckContent )
        {
            $this.set_Force( $true )
        }
        else
        {
            $this.set_Force( $false )
        }
    }

    static [bool] HasMultipleRules ( [string] $CheckContent )
    {
        if ( Test-MultipleUserRightsAssignment -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
        {
            return $true
        }

        return $false
    }

    static [string[]] SplitMultipleRules ( [string] $CheckContent )
    {
        return ( Split-MultipleUserRightsAssignment -CheckContent ( [STIG]::SplitCheckContent( $CheckContent ) ) )
    }
}
#endregion
#region Method Functions
<#
    .SYNOPSIS
        Gets the User Rights Assignment Display Name from the check-content that are assigned to
        the User Rights Assignment policy
#>
function Get-UserRightDisplayName
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    Write-Verbose "match = $($Script:RegularExpression.textBetweenQuotes)"
    # Use a regular expression to pull the user right string from between the quotes
    $userRightDisplayNameSearch = ( $CheckContent |
            Select-String -Pattern $($Script:RegularExpression).textBetweenQuotes -AllMatches )

    [string[]] $userRightDisplayName = $userRightDisplayNameSearch.matches.Groups.Value |
        Where-Object { $script:UserRightNameToConstant.Keys -contains $PSItem }

    if ( $null -ne $userRightDisplayName )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] UserRightDisplayName : $UserRightDisplayName "
        return $userRightDisplayName[0]
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] UserRightDisplayName : Not Found"
    }
}

<#
    .SYNOPSIS
        Enumerates User Rights Assignment Policy display names and converts them to the matching constant
#>
function Get-UserRightConstant
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [parameter(Mandatory = $true)]
        [string]
        $UserRightDisplayName
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $userRightConstant = $script:UserRightNameToConstant.$UserRightDisplayName

    if ( $null -ne $userRightConstant )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Found: $UserRightDisplayName : $userRightConstant "
        $userRightConstant
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Not Found : $UserRightDisplayName "
    }
}

<#
    .SYNOPSIS
        Gets the Identity from the check-content that are assigned to the User Rights Assignment policy
#>
function Get-UserRightIdentity
{
    [CmdletBinding()]
    [OutputType([string[]])]
    Param
    (
        [parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    <#
        Select the line that contains the User Right
        one entry contains multiple lines with the same user right so select the first index
    #>

    $return = [System.Collections.ArrayList] @()

    if ($CheckContent -Match "Administrators\sAuditors\s" -and $CheckContent -Match "DNS\sServer\slog\sfile" )
    {
        [void] $return.Add('Administrators')
    }
    elseif ( $CheckContent -Match "If (any|the following){1} (accounts or groups|groups or accounts) (other than the following|are not defined){1}.*this is a finding" )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Ensure : Present"
        # There is an edge case where multiple finding statements are made, so a zero index is needed.
        [int] $lineNumber = ( ( $CheckContent | Select-String "this is a finding" )[0] ).LineNumber
        # Set the negative index number of the first group to process.
        $startLine = $lineNumber - $CheckContent.Count

        foreach ( $line in $CheckContent[$startLine..-1] )
        {
            if ( $line.Trim() -notmatch ":|^If|^Microsoft|^Organizations|^Vendor|^The|^(Systems|Workstations)\sDedicated" -and -not [string]::IsNullOrEmpty( $line.Trim() ) )
            {
                <#
                    There are a few entries that add the word 'group' to the end of the group name, so
                    they need to be cleaned up.
                #>
                if ($line.Trim() -match "Hyper-V")
                {
                    [void] $return.Add("{Hyper-V}")
                }
                elseif ( $line.Trim() -match "(^Enterprise|^Domain) (Admins|Admin)|^Guests" )
                {
                    if ( $line -match '\sAdmin\s' )
                    {
                        $line = $line -replace 'Admin', 'Admins'
                    }
                    # .Trim method is case sensitive, so the replace operator is used instead
                    [void] $return.Add( $($line.Trim() -replace ' Group').Trim() )
                }
                elseIf ($line.Trim() -match 'Local account and member of Administrators group')
                {
                    [void] $return.Add('Local account')
                }
                else
                {
                    <#
                        The below regex with remove anything between parentheses.
                        This address the edge case where parentheses are used to add a note following the identity
                    #>
                    [void] $return.Add( ($line -replace '\([\s\S]*?\)').Trim() )
                }
            }
        }
    }
    elseif ( $CheckContent -Match "If any (accounts or groups|groups or accounts).*are (granted|defined).*this is a finding" )
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Ensure : Absent"

        [void] $return.Add("NULL")
    }

    $return
}

<#
    .SYNOPSIS
        Looks in the Check-Content element to see if it matches any scrict User Rights Assignments.
#>
function Test-SetForceFlag
{
    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        [parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    if ( $CheckContent -match 'If any (accounts or groups|groups or accounts) other than the following' )
    {
        return $true
    }
    elseif ( $CheckContent -match 'If any (accounts or groups|groups or accounts)\s*(\(.*\),)?\s*are (granted|defined)' )
    {
        return $true
    }

    return $false
}

<#
    .SYNOPSIS
        Supports the ContainsMultipleRules statis method to test for multiple
        user rights assignment rules
#>
function Test-MultipleUserRightsAssignment
{
    [CmdletBinding()]
    [OutputType( [bool] )]
    param
    (
        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $userRightMatches = $CheckContent | Select-String -Pattern 'local computer policy'

    if ( $userRightMatches.count -gt 1 )
    {
        return $true
    }

    return $false
}

<#
    .SYNOPSIS
        Parses STIG check-content to return text pertaining to individual UserRightAssignment rules
#>
function Split-MultipleUserRightsAssignment
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $userRightMatches = $CheckContent | Select-String -Pattern 'local computer policy'
    $i = 1
    foreach ( $match in $userRightMatches )
    {
        $stringBuilder = New-Object System.Text.StringBuilder
        if ($i -ne $userRightMatches.count)
        {
            [string[]] $content = $CheckContent[($match.lineNumber)..($userRightMatches[$i].lineNumber - 2 )]
        }
        else
        {
            [string[]] $content = $CheckContent[($match.lineNumber)..$CheckContent.Length]
        }

        foreach ( $line in $content  )
        {
            [void] $stringBuilder.Append("$line`r`n")
        }
        $i++
        $stringBuilder.ToString()
    }
}
#endregion
