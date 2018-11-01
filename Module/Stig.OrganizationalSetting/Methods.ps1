# Copyright (c) Microsoft Corporation. All rights reserved.
# userRightNameToConstant under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        A static method helper function to return a local varialbe.
        Static methods do not have access to varaibles outside of thier scope.
#>
function Get-PropertyMap
{
    return $propertyMap
}
#endregion
