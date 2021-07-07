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
            $getScript = '$smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                          if (''SQLConnectionName'' -notmatch ''\\'')
                          {
                             $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                             $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                          }
                          else
                          {
                             $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                             $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                          }

                          return @{Result = $smoSqlNamedPipes.IsEnabled}'
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
            $testScript = '$smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                           if (''SQLConnectionName'' -notmatch ''\\'')
                           {
                               $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                               $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                           }
                           else
                           {
                               $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                               $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                           }

                           if ($smoSqlNamedPipes.IsEnabled -eq $True)
                           {
                               return $False
                           }
                           else
                           {
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
            $setScript = '$smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                          if (''SQLConnectionName'' -notmatch ''\\'')
                          {
                              $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                              $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                              $np = $smoSqlConfigServices.GetSmoObject($smoSqlNamedPipes.Urn.Value)
                              $np.IsEnabled = $False
                              $np.Alter()
                          }
                          else
                          {
                              $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                              $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                              $np = $smoSqlConfigServices.GetSmoObject($smoSqlNamedPipes.Urn.Value)
                              $np.IsEnabled = $False
                              $np.Alter()
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
