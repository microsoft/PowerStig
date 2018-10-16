#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $rulesToTest = @(
        @{
            displayName  = 'Act as part of the operating system'
            constant     = 'SeTcbPrivilege'
            Identity     = 'NULL'
            CheckContent = 'Verify the effective setting in Local Group Policy Editor.
            Run "gpedit.msc".
        
            Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.
        
            If any accounts or groups (to include administrators), are granted the "{0}" user right, this is a finding.'
        }
        @{
            displayName  = 'Take ownership of files or other objects'
            constant     = 'SeTakeOwnershipPrivilege'
            Identity     = 'Administrators'
            CheckContent = 'Verify the effective setting in Local Group Policy Editor.
            Run "gpedit.msc".
            
            Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.
            
            If any groups or accounts other than the following are granted the "{0}" user right, this is a finding:
            
            Administrators'
        }
        @{
            displayName  = 'Deny access to this computer from the network'
            constant     = 'SeDenyNetworkLogonRight'
            Identity     = 'Enterprise Admins,Domain Admins,Local account,Guests'
            CheckContent = 'Verify the effective setting in Local Group Policy Editor.
            Run "gpedit.msc".

            Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

            If the following accounts or groups are not defined for the "Deny access to this computer from the network" user right, this is a finding:

            Domain Systems Only:
            Enterprise Admins group
            Domain Admins group
            "Local account and member of Administrators group" or "Local account" (see Note below)

            All Systems:
            Guests group

            Systems dedicated to the management of Active Directory (AD admin platforms, see V-36436 in the Active Directory Domain STIG) are exempt from denying the Enterprise Admins and Domain Admins groups.

            Note: Windows Server 2012 R2 added new built-in security groups, "Local account" and "Local account and member of Administrators group". "Local account" is more restrictive but may cause issues on servers such as systems that provide Failover Clustering.
            Microsoft Security Advisory Patch 2871997 adds the new security groups to Windows Server 2012.'
        }
    )
    #endregion
    #region Tests
    Describe "User Rights Assignment Conversion" {

        foreach ( $testRule in $rulesToTest )
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent ( $testRule.CheckContent -f $testRule.displayName ) -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It "Should return an UserRightRule Object" {
                $rule.GetType() | Should Be 'UserRightRule'
            }
            It "Should extract the correct DisplayName" {
                $rule.DisplayName | Should Be $testRule.displayName
            }
            It "Should return the correct Constant" {
                $rule.Constant | Should Be $testRule.constant
            }
            It "Should extract the correct identity" {
                $rule.Identity | Should Be $testRule.Identity
            }
            It 'Should not have OrganizationValueRequired set' {
                $rule.OrganizationValueRequired | Should Be $false
            }
            It 'Should have emtpty test string' {
                $rule.OrganizationValueTestString | Should BeNullOrEmpty
            }
            It 'Should Set the status to pass' {
                $rule.conversionstatus | Should Be 'pass'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
