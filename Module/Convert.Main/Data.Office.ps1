# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
$global:SingleLineRegistryPath += [ordered]@{
     Office1 = [ordered]@{
          Match  = 'outlook\\security'
          Select = '((HKLM|HKCU).*\\security)'
     }
     Office2 = [ordered]@{ #Added for Outlook Stig V-17761.b
          Match  = 'value for hkcu.*Message\sPlain\sFormat\sMime'
          Select = '(HKCU).*(?<=me)'
     }
}

$global:SingleLineRegistryValueName += [ordered]@{
     Nine     = @{
          Match  = 'If the REG_DWORD'
          Select = '((?<=for\s")(.*)(?<="))'
     }
     Ten      = @{ #Added for Outlook Stig V-17761.b
          Match  = 'Message Plain Format Mime'
          Select = '((?<=il\\)(.*)(?<=e\s))'
     }
     Eleven   = @{ #Added for Outlook Stig V-17575
          Match  = 'Configure trusted add-ins'
          Select = '(?<=ty\\).*(?=\sIn)'
     }
     Twelve   = @{ #Added for Outlook Stig V-17761.a
          Match  = 'a value of between'
          Select = '((?<=gs\\)(.*)(?<=Len))'
     }
     Thirteen = @{ #Added for Outlook Stig V-17774 and V-17775
          Match  = 'FileExtensionsRemoveLevel'
          Select = '(?<=the registry value\s.)(.*)(?=.\We)'
     }
     Fourteen = [ordered]@{ #Added for Outlook Stig V-17733
          Match = 'If the.+(registry key exist)'
          Select = '(?<=ty\\).*(?=\sC)'
     }
}

$global:SingleLineRegistryValueType += [ordered]@{
     Eight = @{
          Select = '((?<=If the\s)(.*)(?<=DWORD))'
     }
     Nine = @{ #Added for Outlook Stig V-17575
          Select = '(?<=\sto\s).*"'
     }
}

$global:SingleLineRegistryValueData += [ordered]@{
     Six = @{ #Added for Outlook Stig V-17776
          Match = 'If the value PublishCalendarDetailsPolicy'
          Select = '((?<=is\s)(.*)(?=\sor))'
     }
     Seven   = @{ #Added for Outlook Stig V-17761.a
          Match  = 'a value of between'
          Select = '(?<=between\s)(.*)(?<=\s)'
     }
     Eight = @{ #Added for Outlook Stig V-17575
          Select = '(?<=\sto\s).*"'
     }
}
