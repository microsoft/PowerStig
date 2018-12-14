# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
$global:SingleLineRegistryPath += [ordered]@{
     Office1 = [ordered]@{
          Match  = 'the policy value'
          Select = '(?<=ty\\)(.*)(?<=)' 
     }
     Office2 = [ordered]@{
          Match  = 'outlook\\security'; 
          Select = '((HKLM|HKCU).*\\security)' 
     }
     Office3 = [ordered]@{
          Match  = 'the value for hkcu.*Message\sPlain\sFormat\sMime'; 
          Select = '((HKLM|HKCU).*(?=\sis))' 
     }   
}

$global:SingleLineRegistryValueName += [ordered]@{
     Nine     = @{
          Match  = 'If the REG_DWORD'
          Select = '((?<=for\s")(.*)(?<="))' 
     } #Added for Outlook Stig - JJS
     Ten      = @{
          Match  = 'Message Plain Format Mime' 
          Select = '((?<=il\\)(.*)(?<=e\s))'
     }
     Eleven   = @{
          Match  = 'Configure trusted add-ins' 
          Select = '(.*(?<=ty\\)(.*)(?<=))'
     }
     Twelve   = @{
          Match  = 'a value of between'
          Select = '((?<=gs\\)(.*)(?<=Len))'
     }
     Thirteen = @{
          Match  = 'FileExtensionsRemoveLevel' 
          Select = '(?<=the registry value\s.)(.*)(?=.\We)'
     }
}

$global:SingleLineRegistryValueType += [ordered]@{
    Eight   = @{ 
        Select = '({0}"?\sis (?!not))(.*=)' 
        Group = 2 
   } 
     Nine = @{
          Select = '((?<=If the\s)(.*)(?<=DWORD))'
     } #Added for Outlook Stig - JJS
}

$global:SingleLineRegistryValueData += [ordered]@{
     Six = @{
          Match = 'If the value PublishCalendarDetailsPolicy' 
          Select = '((?<=is\s)(.*)(?=\sor))'
     } 
     Seven   = @{
        Match  = 'a value of between'
        Select = '(?<=between\s)(.*)(?<=\s)'
   }
#Added for Outlook Stig - JJS
}
# Five = [ordered]@{ Match = 'the policy value'; Select = '(?<=")(.*)(?="\sis)' };
