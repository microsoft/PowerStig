# // Copyright (c) Microsoft Corporation. All rights reserved.// Licensed under the MIT license.

<#
.SYNOPSIS
    This class describes a Technology

.DESCRIPTION
    The Technology class describes a Technology, the definition of the abstracted platform of an application or portion of an application that
    the Stig applies to. This could often be a specific type of OS, but is not limited to that. The Technology is one of a few Technology
    focused classes that work together to form a complete description of the Stig required by the user or application creating the StigData
    instance.

.EXAMPLE
    $technology = [Technology]::new([string] $Name)

.NOTES
    This class requires PowerShell v5 or above.
#>

Class Technology
{
    #region Properties
    <#
    .DESCRIPTION
        The name of a type of technology of the Stig to select
    #>
    [string] $Name

    <#
    .DESCRIPTION
        The available types of technology currently in PowerStig
    #>
    static $ValidateSet = @('Windows', 'SQL')
    #endregion Properties

    #region Constructors
    <#
    .SYNOPSIS
        Parameterless constructor

    .DESCRIPTION
        A parameterless constructor for Technology. To be used only for
        build/unit testing purposes as Pester currently requires it in order to test
        static methods on powershell classes

    .RETURN
        Technology
    #>
    Technology()
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
    .SYNOPSIS
        Constructor

    .DESCRIPTION
        A constructor for Technology. Returns a ready to use instance
        of Technology.

    .PARAMETER Name
        The name of a type of technology of the Stig to select

    .RETURN
        Technology
    #>
    Technology([string] $Name)
    {
        $this.Name = $Name
        if (!($this.Validate()))
        {
            throw("The specified Technology name is not valid. Please check for available Technologies.")
        }
    }
    #endregion Constructors

    #region Methods
    <#
    .SYNOPSIS
        Validates the provided name

    .DESCRIPTION
        This method validates that the provided name for the Technology is
        available in PowerStig

    .RETURN
        bool
    #>
    [bool] Validate ()
    {
        $techs = [Technology]::Available()

        if ($techs -contains $this.Name)
        {
            return $true
        }
        else
        {
            Write-Warning -Message "The Technologies currently available within PowerStig include:`n$($techs -join "`n")"
            return $false
        }
    }
    #endregion Methods

    #region Static Methods
    <#
    .SYNOPSIS
        Returns available Technologies

    .DESCRIPTION
        This method returns Technologies currently available in PowerStig

    .RETURN
        string[]
    #>
    static [string[]] Available ()
    {
        return [Technology]::ValidateSet
    }
    #endregion Static Methods
}
