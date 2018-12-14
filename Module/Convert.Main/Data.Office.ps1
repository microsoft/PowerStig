# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
$global:SingleLineRegistryPath += [ordered]@{
     <#Office1 = [ordered]@{
          Match  = 'the policy value'
          Select = '(?<=ty\\)(.*)(?<=)'
     }
     Office2 = [ordered]@{
          Match  = 'outlook\\security';
          Select = '((HKLM|HKCU).*\\security)'
     }#>
     Office3 = [ordered]@{ #Added for Outlook Stig V-17761.b
          Match  = 'the value for hkcu.*Message\sPlain\sFormat\sMime';
          Select = '((HKLM|HKCU).*(?=\sis\s"))'
     }
}

$global:SingleLineRegistryValueName += [ordered]@{
     Nine     = @{
          Match  = 'If the REG_DWORD'
          Select = '((?<=for\s")(.*)(?<="))'
     }
     Ten      = @{
          Match  = 'Message Plain Format Mime' #Added for Outlook Stig V-17761.b
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
     Nine = @{
          Select = '(?<=\sto\s).*"' #Added for Outlook Stig V-17575
     }
}

$global:SingleLineRegistryValueData += [ordered]@{
     Six = @{
          Match = 'If the value PublishCalendarDetailsPolicy'  #Added for Outlook Stig V-17776
          Select = '((?<=is\s)(.*)(?=\sor))'
     }
     Seven   = @{
          Match  = 'a value of between' #Added for Outlook Stig V-17761
          Select = '(?<=between\s)(.*)(?<=\s)'
     }
     Eight = @{
          Select = '(?<=\sto\s).*"' #Added for Outlook Stig V-17575
     }
}
