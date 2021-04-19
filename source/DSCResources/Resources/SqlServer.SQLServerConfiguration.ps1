# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$Rules = $Stig.RuleList | Select-Rule -Type SqlServerDSCRule

    #Sets variables for Default and Named Instances.
    foreach ($Instance in $ServerInstance)
    {
        Try{
            If($Instance -notmatch "\\"){
                $InstanceName = "MSSQLSERVER"
                $ServerName = $Instance
                #$SQLConnectionName = $HostName
        }
            Else{
                $InstanceName = $Instance.Split("{\}")[1]
                $ServerName = $Instance.Split("{\}")[0]
                #$SQLConnectionName = $SQLInstanceName
            }
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        Write-Verbose $ErrorMessage
    }

        foreach ($rule in $rules)
        {
            Try{
                #XML has placeholder keywords. This replaces placeholder keywords with actual values for configuration.
                #$InstanceName = $Rule.InstanceName
                #$InstanceName = ($InstanceName) | ForEach-Object{$_.replace('SQLInstanceName',$SQLInstanceName)}

                #$ServerName = $Rule.ServerName
                #$ServerName = ($ServerName) | ForEach-Object{$_.replace('HostName',$HostName)}
            
                #Creates correct format for Named Instances.    
                #If($SQLInstanceName -match "\\"){
                #    $InstanceName = $InstanceName.Split("{\}")[1]
                #    $InstanceName = ($InstanceName) | ForEach-Object{$_.replace('SQLInstanceName',$SQLInstanceName)}
                #}

                SqlServerConfiguration (Get-ResourceTitle -Rule $rule)
                {
                    InstanceName = $InstanceName
                    ServerName = $ServerName
                    OptionName = $Rule.OptionName
                    OptionValue = $Rule.OptionValue
                }
            }
            Catch{
                $ErrorMessage = $_.Exception.Message
                Write-Verbose $ErrorMessage
            }
        }
    }