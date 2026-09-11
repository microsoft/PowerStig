# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

class OperatingSystemRule : Rule
{
    [bool] $DomainJoinedOnly
    [string] $RequiredArchitecture
    [string] $RequiredEdition <#(ExceptionValue)#>

    OperatingSystemRule ()
    {
    }

    OperatingSystemRule ([xml.xmlelement] $Rule) : base ($Rule)
    {
    }

    OperatingSystemRule ([xml.xmlelement] $Rule, [switch] $Convert) : base ($Rule, $Convert)
    {
    }

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "$($this.RequiredEdition), $($this.RequiredArchitecture)"
            Notes = 'The operating system edition and architecture required on domain-joined systems.'
        }
    }
}