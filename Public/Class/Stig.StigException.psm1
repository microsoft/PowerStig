# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module .\Stig.StigProperty.psm1

<#
.SYNOPSIS
    This class describes a StigException

.DESCRIPTION
    The StigException class describes a StigException, the collection of StigProperty to override on a specific Stig rule.

.EXAMPLE
    $stigException = [StigException]::new([string] $StigRuleId, [StigProperty[]] $Properties)

.NOTES
    This class requires PowerShell v5 or above.
#>

Class StigException
{
    #region Properties
    <#
    .DESCRIPTION
        The Id of an individual Stig Rule
    #>
    [string] $StigRuleId

    <#
    .DESCRIPTION
        An array of properties and their values to override on a Stig rule
    #>
    [StigProperty[]] $Properties
    #endregion Properties

    #region Constructors
    <#
    .SYNOPSIS
        Parameterless constructor

    .DESCRIPTION
        A parameterless constructor for StigException. To be used only for
        build/unit testing purposes as Pester currently requires it in order to test
        static methods on powershell classes

    .RETURN
        StigException
    #>
    StigException()
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
    .SYNOPSIS
        Constructor

    .DESCRIPTION
        A constructor for StigException. Returns a ready to use instance
        of StigException.

    .PARAMETER StigRuleId
        The Id of an individual Stig Rule

    .PARAMETER Properties
        An array of properties and their values to override on a Stig rule

    .RETURN
        StigException
    #>
    StigException([string] $StigRuleId, [StigProperty[]] $Properties)
    {
        $this.StigRuleId = $StigRuleId
        $this.Properties = $Properties
    }
    #endregion Constructors

    #region Methods
    <#
    .SYNOPSIS
        Adds a StigPropery instance to the StigException Properties property

    .DESCRIPTION
        Adds a StigPropery instance to the StigException Properties property

    .PARAMETER StigProperty
        A StigProperty instance

    .RETURN
        void
    #>
    [void] AddProperty ([StigProperty] $StigProperty)
    {
        $this.Properties += $StigProperty
    }

    <#
    .SYNOPSIS
        Adds a StigPropery instance to the StigException Properties property

    .DESCRIPTION
        Adds a StigPropery instance to the StigException Properties property based on the provided key/value pair

    .PARAMETER Name
        A Stig property name

    .PARAMETER Value
        A Stig property value

    .RETURN
        void
    #>
    [void] AddProperty ([string] $Name, [string] $Value)
    {
        $this.Properties += [StigProperty]::new($Name, $Value)
    }
    #endregion Methods

    #region Static Methods
    <#
    .SYNOPSIS
        Converts a provided hashtable of Stig exceptions into a StigException array

    .DESCRIPTION
        This method returns an StigException array based on the hashtable provided
        as the parameter

    .PARAMETER ExceptionsHashtable
        A hashtable of Stig exceptions

        [hashtable] $StigExceptionHashtable =
            @{
                "V-26606" = @{'ServiceState' = 'Running';
                            'StartupType'= 'Automatic'};
                "V-15683" = @{'ValueData' = '1'};
                "V-26477" = @{'Identity' = 'Administrators'};
            }

    .RETURN
        StigException[]
    #>
    static [StigException[]] ConvertFrom ([Hashtable] $ExceptionsHashtable)
    {
        [System.Collections.ArrayList] $stigExceptions = @()

        foreach ($rule in $ExceptionsHashtable.GetEnumerator())
        {
            [System.Collections.ArrayList] $stigProperties = @()

            foreach ($prop in $rule.Value.GetEnumerator())
            {
                $stigProperties.Add([StigProperty]::new($prop.Key, $prop.Value))
            }

            $stigException = [StigException]::new($rule.Key, $stigProperties)
            $stigExceptions.Add($stigException)
        }

        return $stigExceptions
    }
    #endregion Static Methods
}
