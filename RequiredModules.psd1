@{
    # Set up a mini virtual environment...
    PSDependOptions             = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{

        }
    }

    InvokeBuild                 = 'latest'
    PSScriptAnalyzer            = 'latest'
    Pester                      = 'latest'
    Plaster                     = 'latest'
    ModuleBuilder               = '1.0.0'
    ChangelogManagement         = 'latest'
    Sampler                     = 'latest'
    AuditPolicyDsc              = '1.2.0.0'
    AuditSystemDsc              = '1.1.0'
    AccessControlDsc            = '1.4.0.0'
    ComputerManagementDsc       = '6.2.0.0'
    FileContentDsc              = '1.1.0.108'
    GPRegistryPolicyDsc         = '1.2.0'
    PSDscResources              = '2.10.0.0'
    SecurityPolicyDsc           = '2.4.0.0'
    SqlServerDsc                = '13.3.0'
    WindowsDefenderDsc          = '1.0.0.0'
    xDnsServer                  = '1.11.0.0'
    xWebAdministration          = '2.5.0.0'
}
