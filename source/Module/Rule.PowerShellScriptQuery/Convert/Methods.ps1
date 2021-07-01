# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule GetScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-GetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkcontent) 
    {
        {$PSItem -Match "Named Pipes"}
        {
            $getScript = '$SMOSQLConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')
                          If(''SQLConnectionName'' -notmatch "\\"){
                              $SMOSQLAgent = $SMOSQLConfigServices.ServerInstances | Where-Object{$_.Name -eq ''SQLInstanceName''}
                              $SMOSQLNamedPipes = $SMOSQLAgent.ServerProtocols | Where-Object{$_.Name -eq "np"}
                          }
                              Else{
                                  $SMOSQLAgent = $SMOSQLConfigServices.ServerInstances | Where-Object{$_.Name -eq ''SQLInstanceName''.Split("{\}")[1]}
                                  $SMOSQLNamedPipes = $SMOSQLAgent.ServerProtocols | Where-Object{$_.Name -eq "np"}
                              }

                              return @{Result = $SMOSQLNamedPipes.IsEnabled}'
        }       
    }

    return $getScript
}

<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule TestScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-TestScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match "Named Pipes"}
        {
            $testScript = '$SMOSQLConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')
                           If(''SQLConnectionName'' -notmatch "\\"){
                               $SMOSQLAgent = $SMOSQLConfigServices.ServerInstances | Where-Object{$_.Name -eq ''SQLInstanceName''}
                               $SMOSQLNamedPipes = $SMOSQLAgent.ServerProtocols | Where-Object{$_.Name -eq "np"}
                           }
                              Else{
                                 $SMOSQLAgent = $SMOSQLConfigServices.ServerInstances | Where-Object{$_.Name -eq ''SQLInstanceName''.Split("{\}")[1]}
                                 $SMOSQLNamedPipes = $SMOSQLAgent.ServerProtocols | Where-Object{$_.Name -eq "np"}
                              }
                              
                           If($SMOSQLNamedPipes.IsEnabled -eq $True){
                               return $False
                           }
                              Else{
                                  return $True
                              }'
        }
    }

    return $testScript
}

<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule SetScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-SetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match "Named Pipes"}
        {
            $setScript = '$SMOSQLConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')
                          If(''SQLConnectionName'' -notmatch "\\"){
                              $SMOSQLAgent = $SMOSQLConfigServices.ServerInstances | Where-Object{$_.Name -eq ''SQLInstanceName''}
                              $SMOSQLNamedPipes = $SMOSQLAgent.ServerProtocols | Where-Object{$_.Name -eq "np"}
                              $Np = $SMOSQLConfigServices.GetSmoObject($SMOSQLNamedPipes.Urn.Value)
                              $Np.IsEnabled = $False
                              $Np.Alter()
                          }
                              Else{
                                $SMOSQLAgent = $SMOSQLConfigServices.ServerInstances | Where-Object{$_.Name -eq ''SQLInstanceName''.Split("{\}")[1]}
                                $SMOSQLNamedPipes = $SMOSQLAgent.ServerProtocols | Where-Object{$_.Name -eq "np"}
                                $Np = $SMOSQLConfigServices.GetSmoObject($SMOSQLNamedPipes.Urn.Value)
                                $Np.IsEnabled = $False
                                $Np.Alter()
                              }'
        }
    }

    return $setScript
}

<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule SetScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Set-DependsOn
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match "Windows Start Menu and/or Control Panel,"}
        {
            $setDependsOn = '[SqlServerNetwork][V-213990][medium][SRG-APP-000383-DB-000364]::[SqlServer]BaseLine'
        }
        default
        {
            $setDependsOn = ''
        }
    }

    return $setDependsOn
}
