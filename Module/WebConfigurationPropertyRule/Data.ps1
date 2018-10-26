# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

data RegularExpression
{
    ConvertFrom-StringData -stringdata @'
        autoEncryptionMethod    = "Auto" is selected for the Encryption method
        CGIModules              = "Allow unspecified CGI modules"
        configSection           = (?<=\")system.+?(?=\")
        expiredSession          = Regenerate expired session ID
        HMACSHA256              = Verify "HMACSHA256" is selected for the Validation method
        ISAPIModules            = "Allow unspecified ISAPI modules"
        keyValuePairLine        = Verify.+?(reflects|is set to)
        useCookies              = (Use Cookies|UseCookies)
        sessionTimeout          = Time\-out
'@
}
