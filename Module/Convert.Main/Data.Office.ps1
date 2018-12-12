# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
$global:SingleLineRegistryPath += 
     [ordered]@{
         #     Five = [ordered]@{ Match = 'the policy value'; Select = '(?<=")(.*)(?="\sis)' };
          Office1 = [ordered]@{
               Match='Configure trusted add-ins';
               Select='(.*(?<=ty\\)(.*)(?<=))'
          }
          Office2= [ordered]@{
               Match='outlook\\security';
               Select='((HKLM|HKCU).*\\security)'
          
          Office3= [ordered]@{
               Match='Message Plain Format Mime';
               Select='((?<=il\\)(.*)(?<=e\s))'
          }
          Office4= [ordered]@{
               Match='the value of between';
               Select='((?<=gs\\)(.*)(?<=Len))'
          }
          Office5= [ordered]@{
               Match='FileExtensionsRemoveLevel';
               Select='(?<=the registry value\s.)(.*)(?=.\We)'
          }
     }
}

$global:SingleLineRegistryValueName +=
     [ordered]@{
          Nine = @{ Match = 'If the REG_DWORD'; Select = '((?<=for\s")(.*)(?<="))'}; #Added for Outlook Stig - JJS
          Ten = @{ Match = 'Message Plain Format Mime'; Select = '((?<=il\\)(.*)(?<=e\s))'};
     }

$global:SingleLineRegistryValueType +=
     [ordered]@{
     Eight = @{ Select = '((?<=If the\s)(.*)(?<=DWORD))'}; #Added for Outlook Stig - JJS
    }

$global:SingleLineRegistryValueData +=
     [ordered]@{
     Six = @{ Match = 'If the value PublishCalendarDetailsPolicy'; Select = '((?<=is\s)(.*)(?=\sor))'} #Added for Outlook Stig - JJS
    }
