# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.SYNOPSIS
    This class describes a StigProperty

.DESCRIPTION
    The StigProperty class describes a StigProperty, the abstracted key/value pair definition of any property within a Stig rule. A collection of StigProperty
    instances combine to for a complete description of a Stig rule. StigException instances are made up of a collection of StigProperty in order to
    override the existing values of those properties.

.EXAMPLE
    $stigProperty = [StigProperty]::new([string] $Name, [string] $Value)

.NOTES
    This class requires PowerShell v5 or above.
#>

Class StigProperty
{
    #region Properties
    <#
    .DESCRIPTION
        The name of an individual property on a Stig Rule
    #>
    [string] $Name

    <#
    .DESCRIPTION
        The value of an individual property on a Stig Rule
    #>
    [string] $Value
    #endregion Properties

    #region Constructors
    <#
    .SYNOPSIS
        Parameterless constructor

    .DESCRIPTION
        A parameterless constructor for StigProperty. To be used only for
        build/unit testing purposes as Pester currently requires it in order to test
        static methods on powershell classes

    .RETURN
        StigProperty
    #>
    StigProperty()
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
    .SYNOPSIS
        Constructor

    .DESCRIPTION
        A constructor for StigProperty. Returns a ready to use instance
        of StigProperty.

    .PARAMETER Name
        The name of an individual property on a Stig Rule

    .PARAMETER Value
        The value of an individual property on a Stig Rule

    .RETURN
        StigProperty
    #>
    StigProperty ([string] $Name, [string] $Value)
    {
        $this.Name = $Name
        $this.Value = $Value
    }
    #endregion Constructors
}
