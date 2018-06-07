# // Copyright (c) Microsoft Corporation. All rights reserved.// Licensed under the MIT license.

# In order to merge in the localsettings and orgsettings data, we need a table that can translate
# the unique values that are settable for each type of STIG object
@{
    AccountPolicyRule            = 'PolicyValue'

    AuditPolicyRule              = 'Ensure'

    RegistryRule                 = 'ValueData'

    SecurityOptionRule           = 'OptionValue'

    ServiceRule                  = 'StartupType'

    UserRightRule                = 'Identity'

    WebAppPoolRule               = 'Value'

    WebConfigurationPropertyRule = 'Value'
}
