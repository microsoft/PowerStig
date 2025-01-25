#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try 
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                OptionName                = 'xp_cmdshell'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'The xp_cmdshell extended stored procedure allows execution of host executables outside the controls of database access permissions. This access may be exploited by malicious users who have compromised the integrity of the SQL Server database process to control the host operating system to perpetrate additional malicious activity. 

                To determine if xp_cmdshell is enabled, execute the following commands: 
                
                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''xp_cmdshell''; 
                
                If the value of "config_value" is "0", this is not a finding. 
                
                Review the system documentation to determine whether the use of "xp_cmdshell" is required and approved. If it is not approved, this is a finding.'
            },
            @{
                OptionName                = 'clr enabled'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'The common language runtime (CLR) component of the .NET Framework for Microsoft Windows in SQL Server allows you to write stored procedures, triggers, user-defined types, user-defined functions, user-defined aggregates, and streaming table-valued functions, using any .NET Framework language, including Microsoft Visual Basic .NET and Microsoft Visual C#. CLR packing assemblies can access resources protected by .NET Code Access Security when it runs managed code. Specifying UNSAFE enables the code in the assembly complete freedom to perform operations in the SQL Server process space that can potentially compromise the robustness of SQL Server. UNSAFE assemblies can also potentially subvert the security system of either SQL Server or the common language runtime. 

                To determine if CLR is enabled, execute the following commands: 
                
                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''clr enabled''; 
                
                If the value of "config_value" is "0", this is not a finding. 
                
                If the value of "config_value" is "1", review the system documentation to determine whether the use of CLR code is approved. If it is not approved, this is a finding. 
                
                If CLR code is approved, check the database for UNSAFE assembly permission using the following script: 
                
                USE [master]
                SELECT * 
                FROM sys.assemblies 
                WHERE permission_set_desc != ''SAFE'' 
                AND is_user_defined = 1;
                
                If any records are returned, review the system documentation to determine if the use of UNSAFE assemblies is approved. If it is not approved, this is a finding.'
            },
            @{
                OptionName                = 'common criteria compliance enabled'
                OptionValue               = '1'
                OrganizationValueRequired = $false
                CheckContent              = 'Review system documentation to determine if Common Criteria Compliance is not required due to potential impact on system performance. 

                SQL Server Residual Information Protection (RIP) requires a memory allocation to be overwritten with a known pattern of bits before memory is reallocated to a new resource. Meeting the RIP standard can contribute to improved security; however, overwriting the memory allocation can slow performance. After the common criteria compliance enabled option is enabled, the overwriting occurs. 
                
                Review the Instance configuration: 
                
                
                SELECT value_in_use
                FROM sys.configurations
                WHERE name = ''common criteria compliance enabled''
                
                If "value_in_use" is set to "1" this is not a finding.
                If "value_in_use" is set to "0" this is a finding. 
                
                NOTE: Enabling this feature may impact performance on highly active SQL Server instances. If an exception justifying setting SQL Server Residual Information Protection (RIP) to disabled (value_in_use set to "0") has been documented and approved, then this may be downgraded to a CAT III finding.'
            },
            @{
                OptionName                = 'filestream access level' 
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'Review the system documentation to see if FileStream is in use. If in use authorized, this is not a finding. 

                If FileStream is not documented as being authorized, execute the following query.
                EXEC sp_configure ''filestream access level''
                
                If "run_value" is greater than "0", this is a finding.
                
                
                
                This rule checks that Filestream SQL specific option is disabled.
                
                SELECT CASE 
                 WHEN EXISTS (SELECT * 
                 FROM sys.configurations 
                 WHERE Name = ''filestream access level'' 
                 AND Cast(value AS INT) = 0) THEN ''No'' 
                 ELSE ''Yes''
                 END AS TSQLFileStreamAccess;
                
                If the above query returns "Yes" in the "FileStreamEnabled" field, this is a finding.'
            },
            @{
                OptionName                = 'Ole Automation Procedures'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'To determine if "Ole Automation Procedures" option is enabled, execute the following query: 

                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''Ole Automation Procedures''; 
                
                If the value of "config_value" is "0", this is not a finding. 
                
                If the value of "config_value" is "1", review the system documentation to determine whether the use of "Ole Automation Procedures" is required and authorized. If it is not authorized, this is a finding.'
            },
            @{
                OptionName                = 'user options'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'To determine if "User Options" option is enabled, execute the following query:

                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''user options''; 
                
                If the value of "config_value" is "0", this is not a finding. 
                
                If the value of "config_value" is "1", review the system documentation to determine whether the use of "user options" is required and authorized. If it is not authorized, this is a finding.'
            },
            @{
                OptionName                = 'remote access'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'To determine if "Remote Access" option is enabled, execute the following query: 

                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''remote access''; 
                
                If the value of "config_value" is "0", this is not a finding. 
                
                If the value of "config_value" is "1", review the system documentation to determine whether the use of "Remote Access" is required (linked servers) and authorized. If it is not authorized, this is a finding.'
            },
            @{
                OptionName                = 'hadoop connectivity'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'To determine if "Hadoop Connectivity" option is enabled, execute the following query: 

                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''hadoop connectivity''; 
                
                If the value of "config_value" is "0", this is not a finding.
                
                If the value of "config_value" is "1", review the system documentation to determine whether the use of "Hadoop Connectivity" option is required and authorized. If it is not authorized, this is a finding.'
            },
            @{
                OptionName                = 'allow polybase export'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'To determine if "Allow Polybase Export" option is enabled, execute the following query: 

                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''allow polybase export''; 
                
                If the value of "config_value" is "0", this is not a finding.
                
                If the value of "config_value" is "1", review the system documentation to determine whether the use of "Allow Polybase Export" is required and authorized. If it is not authorized, this is a finding.'
            },
            @{
                OptionName                = 'remote data archive'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'To determine if "Remote Data Archive" option is enabled, execute the following query: 

                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''remote data archive''; 
                
                If the value of "config_value" is "0", this is not a finding. 
                
                If the value of "config_value" is "1", review the system documentation to determine whether the use of "Remote Data Archive" is required and authorized. If it is not authorized, this is a finding.'
            },
            @{
                OptionName                = 'external scripts enabled'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'To determine if "External Scripts Enabled" option is enabled, execute the following query: 

                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''external scripts enabled''; 
                
                If the value of "config_value" is "0", this is not a finding. 
                
                If the value of "config_value" is "1", review the system documentation to determine whether the use of "External Scripts Enabled" is required and authorized. If it is not authorized, this is a finding.'
            },
            @{
                OptionName                = 'replication xps'
                OptionValue               = '0'
                OrganizationValueRequired = $false
                CheckContent              = 'To determine if the "Replication Xps" option is enabled, execute the following query: 

                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''replication xps''; 
                
                If the value of "config_value" is "0", this is not a finding. 
                
                If the value of "config_value" is "1", review the system documentation to determine whether the use of "Replication Xps" is required and authorized. If it is not authorized, this is a finding.'
            },
            @{
                OptionName                  = 'user connections'
                OptionValue                 = '3000'
                OrganizationValueRequired = $false
                CheckContent                = 'Review the system documentation to determine whether any concurrent session limits have been defined. If it does not, assume a limit of 10 for database administrators and 2 for all other users. 
 
                If a mechanism other than a logon trigger is used, verify its correct operation by the appropriate means. If it does not work correctly, this is a finding.

                Due to excessive CPU consumption when utilizing a logon trigger, an alternative method of limiting concurrent sessions is setting the max connection limit within SQL Server to an appropriate value. This serves to block a distributed denial-of-service (DDOS) attack by limiting the attacker''s connections while allowing a database administrator to still force a SQL connection.

                In SQL Server Management Studio''s Object Explorer tree:
                Right-click on the Server Name >> Select Properties >> Select Connections Tab

                OR

                Run the query:
                EXEC sys.sp_configure N''user connections''

                If the max connection limit is set to 0 (unlimited) or does not match the documented value, this is a finding.
                
                Otherwise, determine if a logon trigger exists:  
                
                In SQL Server Management Studio''s Object Explorer tree:  
                Expand [SQL Server Instance] >> Server Objects >> Triggers  
                
                OR 
                
                Run the query:  
                SELECT name FROM master.sys.server_triggers;  
                
                If no triggers are listed, this is a finding.  
                
                If triggers are listed, identify the trigger(s) limiting the number of concurrent sessions per user. If none are found, this is a finding. If they are present but disabled, this is a finding.  
                
                Examine the trigger source code for logical correctness and for compliance with the documented limit(s). If errors or variances exist, this is a finding.
                
                Verify that the system does execute the trigger(s) each time a user session is established. If it does not operate correctly for all types of user, this is a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'Method Function Tests' {
            foreach ($testRule in $testRuleList)
            {

                $optionName = Get-OptionName -CheckContent $testRule.CheckContent

                Context "SqlServerConfiguration Get-OptionName"{
                    It "Should return $($optionName)" {
                        $optionName | Should Be $testrule.OptionName
                    }
                }

                $optionValue = Set-OptionValue -CheckContent $testRule.CheckContent

                Context "SqlServerConfiguration Set-OptionValue" {
                    It "Should return $($optionValue)" {
                        $optionValue | Should Be $testrule.OptionValue
                    }
                }

                . $PSScriptRoot\Convert.CommonTests.ps1

            }
        } 
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
