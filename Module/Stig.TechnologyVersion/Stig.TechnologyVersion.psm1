#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
#endregion
#region Class
<#
    .SYNOPSIS
        This class describes a TechnologyVersion

    .DESCRIPTION
        The TechnologyVersion class describes a TechnologyVersion, the definition of the specific version of the application or portion of an application that
        the Stig applies to. The TechnologyVersion is one of a few Technology focused classes that work together to form a complete
        description of the Stig required by the user or application creating the StigData instance.

    .EXAMPLE
        $technologyVersion = [TechnologyVersion]::new([string] $Name, [Technology] $Technology)

    .NOTES
        This class requires PowerShell v5 or above.
#>
Class TechnologyVersion 
{
    #region Properties
    <#
        .DESCRIPTION
            The name of a version of technology of the Stig to select
    #>
    [string] $Name

    <#
        .DESCRIPTION
            The Technology instance for the selected version
    #>
    [Technology] $Technology

    <#
        .DESCRIPTION
            The available versions for each technology currently in PowerStig
    #>
    static $ValidateSet = @"
Windows = All, 2016, 2012R2, 10
SQL = Server2012
"@
    #endregion
    #region Constructors
    <#
        .SYNOPSIS
            Parameterless constructor

        .DESCRIPTION
            A parameterless constructor for TechnologyVersion. To be used only for
            build/unit testing purposes as Pester currently requires it in order to test
            static methods on powershell classes
    #>
    TechnologyVersion() 
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
        .SYNOPSIS
            Constructor

        .DESCRIPTION
            A constructor for TechnologyVersion. Returns a ready to use instance
            of TechnologyVersion.

        .PARAMETER Name
            The Technology for the selected version

        .PARAMETER Technology
            The Technology instance for the selected version
    #>
    TechnologyVersion ([string] $Name, [Technology] $Technology) 
    {
        $this.Name = $Name
        $this.Technology = $Technology
        if (!($this.Validate())) 
        {
            throw("The specified Version name is not valid. Please check for available Versions.")
        }
    }
    #endregion
    #region Methods
    <#
        .SYNOPSIS
            Validates the provided name

        .DESCRIPTION
            This method validates that the provided name for the TechnologyVersion is
            available for a given Technology in PowerStig
    #>
    [bool] Validate () 
    {
        $versions = [TechnologyVersion]::Available($this.Technology)

        if ($versions -contains $this.Name) 
        {
            return $true
        }
        else 
        {
            Write-Warning -Message "The Versions currently available within PowerStig for $($this.Technology.Name) include:`n$($versions -join "`n")"
            return $false
        }
    }
    #endregion
    #region Static Methods
    <#
        .SYNOPSIS
            Returns available TechnologyVersions

        .DESCRIPTION
            This method returns TechnologyVersions for a given Technology name currently available in PowerStig

        .PARAMETER TechnologyVersion
            The Technology name
    #>
    static [string[]] Available ([Technology] $Technology) 
    {
        $versions = ConvertFrom-StringData -StringData $([TechnologyVersion]::ValidateSet)
        $technologyString = $Technology.ToString()
        
        if ($versions.$technologyString) 
        {
            return $versions.$technologyString.Split(',').Trim()
        }
        else 
        {
            throw("No Versions are available for the Technology you have specified. Please check available Technologies and run again.")
        }
    }
    #endregion
}
#endregion
#region Footer
Foreach ($supportFile in (Get-ChildItem -Path $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name))
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'
#endregion
