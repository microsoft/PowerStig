# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        A Root Certificate Rule object.
    .DESCRIPTION
        The Root Certificate class is used to ensure DOD root certs exist on systems.
    .PARAMETER Thumbprint
        A string with value with the certificate thumbprint.
    .PARAMETER CertificateName
        A string with value with the certificate name.
    .PARAMETER Location
        A string with the value of the file path to the certificate.
#>
class RootCertificateRule : Rule
{
    [string] $Thumbprint
    [string] $CertificateName
    [string] $Location <#(ExceptionValue)#>

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method.
    #>
    RootCertificateRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory.
        .PARAMETER Rule
            The STIG rule to load.
    #>
    RootCertificateRule ([xml.xmlelement] $Rule) : base ($Rule)
    {
    }

    <#
        .SYNOPSIS
            The Convert child class constructor.
        .PARAMETER Rule
            The STIG rule to convert.
        .PARAMETER Convert
            A simple bool flag to create a unique constructor signature.
    #>
    RootCertificateRule ([xml.xmlelement] $Rule, [switch] $Convert) : base ($Rule, $Convert)
    {
    }

    <#
        .SYNOPSIS
            Creates class specifc help content.
    #>
    [hashtable] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
