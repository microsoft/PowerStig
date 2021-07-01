# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$Rules = $Stig.RuleList | Select-Rule -Type PowerShellScriptQueryRule

    #Creates variable with SQL Server Instance Name.
    foreach ($Instance in $ServerInstance)
    {
        Try{
            #Default Instance.
            If($Instance -notmatch "\\"){
                $SQLInstanceName = "MSSQLSERVER"
                $HostName = $Instance
                $SQLConnectionName = $HostName
                $Session = New-PSSession -ComputerName $HostName
                $SQLInstanceRegistry = Invoke-Command -Session $Session -ScriptBlock{Get-ItemProperty "HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL" | Select-Object $Using:SQLInstanceName}
                $SQLInstanceRegistry = $SQLInstanceRegistry.MSSQLSERVER
            }
            
            Else{
                #Named Instance.
                $SQLInstanceName = $Instance
                $HostName = $SQLInstanceName.Split("{\}")[0]
                $SQLConnectionName = $SQLInstanceName
                $SQLRegistry = $SQLInstanceName.Split("{\}")[1]
                $Session = New-PSSession -ComputerName $HostName
                $SQLInstanceRegistry = Invoke-Command -Session $Session -ScriptBlock{Get-ItemProperty "HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL" | Select-Object $SQLRegistry}
                $SQLInstanceRegistry = $SQLInstanceRegistry.$SQLRegistry
            }
        
        #Finds SQL Version.
        $SQLVersion = Invoke-Command -Session $Session -ScriptBlock{Get-ItemProperty "HKLM:\Software\Microsoft\Microsoft SQL Server\$Using:SQLInstanceRegistry\MSSQLSERVER\CurrentVersion" | Select-Object "CurrentVersion"}
        $SQLVersion = $SQLVersion.CurrentVersion.Split("{.}")[0]
        Remove-PSSession -ComputerName $HostName

        }
        Catch
        {
            $ErrorMessage = $_.Exception.Message
            Write-Verbose $ErrorMessage
        }

        foreach ($rule in $rules)
        {
            Try{
                #XML file has placeholder key words. This replaces the placeholder keywords with actual values for configuration.
                $SetScript = $Rule.SetScript
                $SetScript = ($SetScript) | ForEach-Object{$_.replace('SQLVersion',$SQLVersion).replace('SQLInstanceName',$SQLInstanceName).replace('HostName',$HostName).replace('SQLConnectionName',$SQLConnectionName).replace('AuditAdmin',$AuditMaintainers.AuditAdmin).Replace('AuditGroup',$AuditMaintainers.AuditGroup)}

                $TestScript = $Rule.TestScript
                $TestScript = ($TestScript) | ForEach-Object{$_.replace('SQLVersion',$SQLVersion).replace('SQLInstanceName',$SQLInstanceName).replace('HostName',$HostName).replace('SQLConnectionName',$SQLConnectionName).replace('AuditAdmin',$AuditMaintainers.AuditAdmin).Replace('AuditGroup',$AuditMaintainers.AuditGroup)}

                $GetScript = $Rule.GetScript
                $GetScript = ($GetScript) | ForEach-Object{$_.replace('SQLVersion',$SQLVersion).replace('SQLInstanceName',$SQLInstanceName).replace('HostName',$HostName).replace('SQLConnectionName',$SQLConnectionName).replace('AuditAdmin',$AuditMaintainers.AuditAdmin).Replace('AuditGroup',$AuditMaintainers.AuditGroup)}

                Script (Get-ResourceTitle -Rule $rule)
                {
                    GetScript       = $GetScript
                    TestScript      = $TestScript
                    SetScript       = $SetScript
                }
            }
            Catch{
                $ErrorMessage = $_.Exception.Message
                Write-Verbose $ErrorMessage
            }
        }
    }