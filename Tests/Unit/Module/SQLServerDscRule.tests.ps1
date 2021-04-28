#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try 
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                OptionName = 'xp_cmdshell'
                OptionValue = '0'
                OrganizationValueRequired = $false
                CheckContent = 'The xp_cmdshell extended stored procedure allows execution of host executables outside the controls of database access permissions. This access may be exploited by malicious users who have compromised the integrity of the SQL Server database process to control the host operating system to perpetrate additional malicious activity. 

                To determine if xp_cmdshell is enabled, execute the following commands: 
                
                EXEC SP_CONFIGURE ''show advanced options'', ''1''; 
                RECONFIGURE WITH OVERRIDE; 
                EXEC SP_CONFIGURE ''xp_cmdshell''; 
                
                If the value of "config_value" is "0", this is not a finding. 
                
                Review the system documentation to determine whether the use of "xp_cmdshell" is required and approved. If it is not approved, this is a finding.'
            },
            @{
                OptionName = 'clr enabled'
                OptionValue = '0'
                OrganizationValueRequired = $false
                CheckContent = 'The common language runtime (CLR) component of the .NET Framework for Microsoft Windows in SQL Server allows you to write stored procedures, triggers, user-defined types, user-defined functions, user-defined aggregates, and streaming table-valued functions, using any .NET Framework language, including Microsoft Visual Basic .NET and Microsoft Visual C#. CLR packing assemblies can access resources protected by .NET Code Access Security when it runs managed code. Specifying UNSAFE enables the code in the assembly complete freedom to perform operations in the SQL Server process space that can potentially compromise the robustness of SQL Server. UNSAFE assemblies can also potentially subvert the security system of either SQL Server or the common language runtime. 

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
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        foreach ($testRule in $testRuleList)
        {
            BeforeDiscovery {
                $content = New-Object -TypeName PSObject @{
                    'OptionValue'  = $testRule.OptionValue
                    'CheckContent' = $testRule.CheckContent

                }
            }
        
            Describe 'SQLServerConfigurationDSC' -ForEach $content {
            # TODO move this to the CommonTests
                BeforeAll {
                    $content = $_
                }

                It "Should return checkcontent and optionvalue" {
                    $content.CheckContent | Should -Not -BeNullOrEmpty
                    $content.OptionValue | Should -Be '0'
                }
            }
        }   
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}