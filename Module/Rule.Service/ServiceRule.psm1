# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The ServiceRule class is used to maange the Account Policy Settings.
    .PARAMETER ServiceName
        The service name
    .PARAMETER ServiceState
        The state the service should be in
    .PARAMETER StartupType
        The startup type of the service
    .PARAMETER Ensure
        A present or absent flag
#>
Class ServiceRule : Rule
{
    [string] $ServiceName
    [string] $ServiceState
    [string] $StartupType <#(ExceptionValue)#>
    [ensure] $Ensure

    ServiceRule () {}

    ServiceRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    ServiceRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.ServiceName  = $Rule.ServiceName
        $this.ServiceState = $Rule.ServiceState
        $this.StartupType  = $Rule.StartupType
        $this.Ensure       = $Rule.Ensure
    }

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
