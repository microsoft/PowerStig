<#
    .SYNOPSIS
        This function is used to backup a systems security configuration settings prior to applying PowerSTIG.

    .DESCRIPTION
        This runction utilizes the get method of Invoke-Dscresource to find existing system settings. It collects the found settings
        and outputs into a CSV file for later use.

    .PARAMETER BackupLocation
        Specifies the location to store the backup file.

    .PARAMETER StigName
        Specifies the name of STIG to target for backup operation. The name of the STIG can be found under PowerSTIG/StigData/Processed.

    .NOTES
        This script is meant for use in a development environment

    .EXAMPLE
        Backup-StigSettings -BackupLocation "C:\Backup.csv" -StigName "WindowsClient-10-2.1.xml"
#>

function Backup-StigSettings
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $BackupLocation = $ENV:TEMP,

        [Parameter(Mandatory = $true)]
        [string]
        $StigName

    )

    $xmlPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\StigData\Processed'

    $exclusion = @("*.org.default.xml","RHEL*","Ubuntu*","Vsphere*")
    $validStigs = Get-ChildItem $xmlPath -Exclude $exclusion

    if ($validStigs.Name -notContains $StigName.Trim())
    {
        $errorArray = $validStigs.Name -join("`n")
        Write-Host "StigName not valid, options are :`n$errorArray"
        break
    }

    # Load target powerstig process xml
    $powerSTIGLocation = Join-Path -Path $xmlPath -ChildPath $stigName
    [xml] $stig =  Get-Content -Path $powerSTIGLocation

    $ruleList = ""
    foreach ($validStig in $validStigs.FullName)
    {
        [xml] $stigProcess = Get-Content -Path $validStig
        [string[]] $ruleList += ($stigProcess.DISASTIG.ChildNodes.GetEnumerator() | Where-Object -Property dscresourcemodule -ne None).Name
        $rulesUnique = $rulelist | Sort-Object -Unique
    }

    $hashtable = @()

    foreach ($ruletype in $rulesUnique)
    {
        $rules = $stig.DISASTIG.$ruleType.Rule
        $dscResourceModule = $stig.DISASTIG.$ruleType.dscresourcemodule

        foreach ($rule in $rules)
        {
            Switch ($rule.dscResource)
            {
                AccountPolicy {
                    $get = Invoke-DscResource -ModuleName $dscResourceModule -Name $rule.dscResource -Method get -Property @{
                        Name = $rule.PolicyName
                    }

                    $concatPolicyName = $rule.PolicyName.Replace(" ","_")
                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "Name"              = $concatPolicyName
                        "PolicyValue"       = $get.$concatPolicyName
                    }
                }
                AuditPolicySubcategory {
                    $get = Invoke-DscResource -ModuleName $dscResourceModule -Name $rule.dscResource -Method get -Property @{
                        Name = $rule.Subcategory
                        AuditFlag = 'success'
                    }

                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "Name"              = $rule.Subcategory
                        "AuditFlag"         = $get.AuditFlag
                        "Ensure"            = $get.Ensure
                    }
                }
                AuditSetting {
                    $get = Invoke-DscResource -ModuleName $dscResourceModule -Name $rule.dscResource -Method get -Property @{
                        Query        = $rule.Query
                        Property     = $rule.Property
                        DesiredValue = $rule.DesiredValue
                        Operator     = $rule.Operator
                    }

                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "Query"             = $rule.Query
                        "Property"          = $rule.Property
                        "DesiredValue"      = $get.DesiredValue
                        "Operator"          = $rule.Operator
                    }
                }
                ProcessMitigation {
                    $get = Invoke-DscResource -ModuleName $dscResourceModule -Name $rule.dscResource -Method get -Property @{
                        MitigationTarget = $rule.MitigationTarget
                        MitigationType   = $rule.MitigationType
                        MitigationName   = $rule.MitigationName
                        MitigationValue  = $rule.MitigationValue
                    }

                    if ($null -eq $get.MitigationValue)
                    {
                        $get.MitigationValue = "False"
                    }

                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "MitigationTarget"  = $rule.MitigationTarget
                        "MitigationType"    = $rule.MitigationType
                        "MitigationName"    = $rule.MitigationName
                        "MitigationValue"   = $get.MitigationValue
                    }
                }
                Registry {
                    if ($rule.key -match "HKEY_LOCAL_MACHINE")
                    {
                        $replace = ($rule.key).replace("HKEY_LOCAL_MACHINE","HKLM:")
                    }
                    else
                    {
                        $replace = ($rule.key).replace("HKEY_CURRENT_USER","HKCU:")
                    }

                    $get = Invoke-DscResource -ModuleName $dscResourceModule -Name $rule.dscResource -Method get -Property @{
                        Key = $replace
                        ValueType   = $rule.ValueType
                        ValueName   = $rule.ValueName
                    }

                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "Key"               = $replace
                        "ValueType"         = $rule.ValueType
                        "ValueName"         = $rule.ValueName
                        "ValueData"         = $get.ValueData
                        "Ensure"            = $get.Ensure
                    }
                }
                RegistryPolicyFile {
                    if ($rule.key -match 'HKEY_CURRENT_USER')
                    {
                        $replace = ($rule.key).replace("HKEY_CURRENT_USER\","")
                        $TargetType = 'UserConfiguration'
                    }
                    else
                    {
                        $replace = ($rule.key).replace("HKEY_LOCAL_MACHINE\","")
                        $TargetType = 'ComputerConfiguration'
                    }

                    $get = Invoke-DscResource -ModuleName "GPRegistryPolicyDsc" -Name $rule.dscResource -Method get -Property @{
                        Key        = $replace
                        ValueType  = $rule.ValueType
                        ValueName  = $rule.ValueName
                        TargetType = $TargetType
                    }

                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "Key"               = $get.Key
                        "ValueType"         = $rule.ValueType
                        "ValueName"         = $rule.ValueName
                        "ValueData"         = $get.ValueData
                        "TargetType"        = $TargetType
                        "Ensure"            = $get.Ensure
                    }
                }
                SecurityOption {
                    $concatOptionName = $rule.OptionName.Replace(" ","_").Replace(":","").Replace("/","_")

                    $get = Invoke-DscResource -ModuleName $dscResourceModule -Name $rule.dscResource -Method get -Property @{
                        Name = $rule.OptionName
                    }

                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "Name"              = $concatOptionName
                        "OptionValue"       = $get.$concatOptionName
                    }
                }
                Service {
                    if ($rule.ServiceName -ne "")
                    {
                        $get = Invoke-DscResource -ModuleName $dscResourceModule -Name $rule.dscResource -Method get -Property @{
                            Name = $rule.ServiceName
                        }

                        $hashtable += @{
                            "DscResourceModule" = $dscResourceModule
                            "DscResource"       = $rule.dscResource
                            "Name"              = $rule.ServiceName
                            "StartupType"       = $get.StartupType
                            "State"             = $get.State
                        }
                    }
                }
                UserRightsAssignment {
                    $concatIdentityName = $rule.DisplayName.Replace(" ","_")
                    $get = Invoke-DscResource -ModuleName $dscResourceModule -Name $rule.dscResource -Method get -Property @{
                        Policy   = $concatIdentityName
                        Identity = @("IdentityName")
                    }

                    $identityString = ($get.Identity) -join ","
                    if ($identityString -eq "Null")
                    {
                        $identityString = " "
                    }

                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "Policy"            = $concatIdentityName
                        "Identity"          = $identityString
                    }
                }
                WindowsOptionalFeature {
                    $get = Get-WindowsOptionalFeature -FeatureName $rule.Name -Online

                    if ($get.State -eq "Disabled")
                    {
                        $ensure = "Absent"
                    }
                    else
                    {
                        $ensure = "Present"
                    }

                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "Name"              = $rule.Name
                        "Ensure"            = $ensure
                    }
                }
                xDnsServerSetting {
                    $get = Invoke-DscResource -ModuleName $dscResourceModule -Name $rule.dscResource -Method get -Property @{
                        Name   = hostname
                    }
                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "NoRecursion"       = $get.NoRecursion
                        "EventLogLevel"     = $get.EventLogLevel
                    }

                }
                NTFSAccessEntry {
                        $inputPath = [System.Environment]::ExpandEnvironmentVariables($rule.Path)
                        $fileSystemItem = Get-Item -Path $inputPath -ErrorAction Stop
                        $currentAcl = $fileSystemItem.GetAccessControl('Access')

                    foreach ($entry in $currentAcl.Access)
                    {
                        $trimIdentity = $entry.IdentityReference -replace ".*\\"
                        $hashtable += @{
                            "DscResourceModule" = $dscResourceModule
                            "DscResource"       = $rule.dscResource
                            "Path"              = $rule.path
                            "IdentityReference" = $trimIdentity
                            "IsInherited"       = $entry.IsInherited
                            "AccessControlType" = $entry.AccessControlType
                            "FileSystemRights"  = $entry.FileSystemRights
                        }
                    }
                }
                RegistryAccessEntry {
                    $inputPath = [System.Environment]::ExpandEnvironmentVariables($rule.Path)
                    $currentACL = Get-Acl -Path $inputPath

                    foreach ($entry in $currentAcl.Access)
                    {
                        $trimIdentity = $entry.IdentityReference -replace ".*\\"
                        $hashtable += @{
                            "DscResourceModule" = $dscResourceModule
                            "DscResource"       = $rule.dscResource
                            "Path"              = $rule.path
                            "IdentityReference" = $trimIdentity
                            "IsInherited"       = $entry.IsInherited
                            "AccessControlType" = $entry.AccessControlType
                            "RegistryRights"    = $entry.RegistryRights
                            "InheritanceFlags"  = $entry.InheritanceFlags
                            "PropagationFlags"  = $entry.PropagationFlags
                        }
                    }
                }
                CertificateDSC {
                    $certificate = dir cert: -Recurse | Where-Object -FilterScript { $_.Thumbprint -like $rule.Thumbprint }

                    if ($rule.CertificateName -match "Interoperability")
                    {
                        $storeLocation = 'Disallowed'
                    }
                    else
                    {
                        $storeLocation = 'Root'
                    }

                    if ($null -eq $certificate)
                    {
                        $Ensure = 'Absent'
                    }
                    else
                    {
                        $Ensure = 'Present'
                    }

                    $hashtable += @{
                        "DscResourceModule" = $dscResourceModule
                        "DscResource"       = $rule.dscResource
                        "Thumbprint"        = $rule.Thumbprint
                        "Store"             = $storeLocation
                        "Location"          = "LocalMachine"
                        "Ensure"            = $Ensure
                    }
                }
            }
        }
    }

    #export results to csv in temp directory
    $path = "{0}\PowerSTIG_backup_{1}_{2}.csv" -f $BackupLocation, $StigName, (Get-Date -f MM_dd_yyyy_hh_mm_ss)
    $hashtable.GetEnumerator() | Select-Object -Property `
    @{N='DscResourceModule';E={$_.DscResourceModule}},`
    @{N='DscResource';E={$_.DscResource}},`
    @{N='Name';E={$_.Name}},`
    @{N='PolicyValue';E={$_.PolicyValue}},`
    @{N='AuditFlag';E={$_.AuditFlag}},`
    @{N='Query';E={$_.Query}},@{N='Property';E={$_.Property}},`
    @{N='DesiredValue';E={$_.DesiredValue}},`
    @{N='Operator';E={$_.Operator}}, `
    @{N='MitigationTarget';E={$_.MitigationTarget}}, `
    @{N='MitigationType';E={$_.MitigationType}}, `
    @{N='MitigationName';E={$_.MitigationName}}, `
    @{N='MitigationValue';E={$_.MitigationValue}}, `
    @{N='Key';E={$_.Key}}, `
    @{N='ValueType';E={$_.ValueType}}, `
    @{N='ValueName';E={$_.ValueName}}, `
    @{N='ValueData';E={$_.ValueData}}, `
    @{N='TargetType';E={$_.TargetType}}, `
    @{N='Ensure';E={$_.Ensure}}, `
    @{N='OptionValue';E={$_.OptionValue}}, `
    @{N='StartupType';E={$_.StartupType}}, `
    @{N='State';E={$_.State}}, `
    @{N='Policy';E={$_.Policy}}, `
    @{N='Identity';E={$_.Identity}}, `
    @{N='AclObject';E={$_.AclObject}}, `
    @{N='NoRecursion';E={$_.NoRecursion}}, `
    @{N='EventLogLevel';E={$_.EventLogLevel}}, `
    @{N='Path';E={$_.Path}}, `
    @{N='IdentityReference';E={$_.IdentityReference}}, `
    @{N='IsInherited';E={$_.IsInherited}}, `
    @{N='AccessControlType';E={$_.AccessControlType}}, `
    @{N='FileSystemRights';E={$_.FileSystemRights}}, `
    @{N='RegistryRights';E={$_.RegistryRights}}, `
    @{N='InheritanceFlags';E={$_.InheritanceFlags}}, `
    @{N='PropagationFlags';E={$_.PropagationFlags}}, `
    @{N='Store';E={$_.Store}}, `
    @{N='Thumbprint';E={$_.Thumbprint}} `
    | Export-Csv -NoTypeInformation -Path $path
}

<#
    .SYNOPSIS
        This function is used to revert to the system state at backup time.

    .DESCRIPTION
        This function utilizes the get method of Invoke-Dscresource to find existing system settings. It collects the found settings
        and outputs into a CSV file for later use.

    .PARAMETER BackupLocation
        Specifies the location to store the backup file.

    .NOTES
        This script is meant for use in a development environment

    .EXAMPLE
        Revert-StigSettings -BackupLocation "C:\backup.csv"
#>
function Restore-StigSettings
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter()]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $BackupLocation = $ENV:TEMP,

        [Parameter(Mandatory = $true)]
        [string]
        $StigName
    )

    $xmlPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\StigData\Processed'
    $exclusion = @("*.org.default.xml","RHEL*","Ubuntu*","Vsphere*")
    $validStigs = Get-ChildItem $xmlPath -Exclude $exclusion

    if ($validStigs.Name -notContains $StigName.Trim())
    {
        $errorArray = $validStigs.Name -join("`n")
        Write-Host "StigName not valid, options are :`n$errorArray"
        break
    }

    # Remove DSC Document to revert system state
    Remove-DscConfigurationDocument -Stage Current -Force

    # Get latest PowerSTIG backup
    $latest = Get-ChildItem -Path $BackupLocation | Where-Object Name -Match $StigName | Select-Object -Last 1
    $importCsv = Import-Csv -Path $latest.FullName

    foreach ($rule in $importCsv)
    {
        Switch ($rule.dscResource)
        {
            AccountPolicy {
                if ($rule.PolicyValue -match "^\d+$")
                {
                    [int] $integer = $rule.PolicyValue

                    Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                        Name       = "Name"
                        $rule.Name = $integer
                    } -ErrorAction Ignore
                }
                else
                {
                    Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                        Name       = "Name"
                        $rule.Name = $rule.PolicyValue
                    } -ErrorAction Ignore
                }
            }
            AuditPolicySubcategory {
                if ($rule.AuditFlag -eq "No Auditing")
                {
                    Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                        Name      = $rule.Name
                        AuditFlag = "Failure"
                        Ensure    = $rule.Ensure
                    }

                    Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                        Name      = $rule.Name
                        AuditFlag = "Success"
                        Ensure    = $rule.Ensure
                    }
                }
                else
                {
                    Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                        Name      = $rule.Name
                        AuditFlag = $rule.AuditFlag
                        Ensure    = $rule.Ensure
                    }
                }
            }
            AuditSetting {
                Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                    Query        = $rule.Query
                    Property     = $rule.Property
                    DesiredValue = $rule.DesiredValue
                    Operator     = $rule.Operator
                }
            }
            ProcessMitigation {
                Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                    MitigationTarget = $rule.MitigationTarget
                    MitigationType   = $rule.MitigationType
                    MitigationName   = $rule.MitigationName
                    MitigationValue  = $rule.MitigationValue
                }
            }
            Registry {
                [string[]] $ValueDataArray = $rule.ValueData

                Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                    Key         = $rule.Key
                    ValueType   = $rule.ValueType
                    ValueName   = $rule.ValueName
                    ValueData   = $ValueDataArray
                    Ensure      = $rule.Ensure
                    Force       = $true
                }
            }
            RegistryPolicyFile {
                [string[]] $ValueDataArray = $rule.ValueData

                Invoke-DscResource -ModuleName "GPRegistryPolicyDsc" -Name $rule.dscResource -Method Set -Property @{
                    Key        = $rule.Key
                    ValueType  = $rule.ValueType
                    ValueName  = $rule.ValueName
                    TargetType = $rule.TargetType
                    ValueData  = $ValueDataArray
                    Ensure     = $rule.Ensure
                }

                if ($rule.Ensure -eq "Absent")
                {
                    if ($rule.TargetType -match 'UserConfiguration')
                    {
                        $replace = '{0}{1}' -f "HKCU:\", $rule.key
                    }
                    else
                    {
                        $replace = '{0}{1}' -f "HKLM:\", $rule.key
                    }
                    Invoke-DscResource -ModuleName $rule.dscResourceModule -Name "Registry" -Method Set -Property @{
                        Key         = $replace
                        ValueType   = $rule.ValueType
                        ValueName   = $rule.ValueName
                        Ensure      = $rule.Ensure
                        Force       = $true
                    }
                }
            }
            SecurityOption {
                Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                    Name       = "Name"
                    $rule.Name = $rule.OptionValue
                }
            }
            Service {
                Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                    Name = $rule.Name
                    StartupType = $rule.StartupType
                    State = $rule.State
                }
            }
            UserRightsAssignment {
                $IdentityArray = ($rule.Identity).Split(",")

                Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                    Policy   = $rule.Policy
                    Identity = $IdentityArray
                    Force    = $true
                }
            }
            WindowsOptionalFeature {
                Invoke-DscResource -ModuleName $rule.dscResourceModule -Name $rule.dscResource -Method Set -Property @{
                    Name   = $rule.Name
                    Ensure = $rule.Ensure
                } -ErrorAction Ignore
            }
        }
    }
}
