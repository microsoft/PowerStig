# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
$global:SingleLineRegistryPath += 
     [ordered]@{
         #     Five = [ordered]@{ Match = 'the policy value'; Select = '(?<=")(.*)(?="\sis)' };

         Office1 = [ordered]@{
                Match = 'the policy value'; 
                Select   = '(?<=ty\\)(.*)(?<=)' 
                };
        Office2 = [ordered]@{
                    Match = 'outlook\\security'; 
                    Select   = '((HKLM|HKCU).*\\security)' 
                };
        Office3 = [ordered]@{
                    Match = 'the value for hkcu.*Message\sPlain\sFormat\sMime'; 
                    Select   = '((HKLM|HKCU).*(?=\sis))' 
                };   
}

$global:SingleLineRegistryValueName +=
     [ordered]@{
     Eight = @{ Match = 'If the REG_DWORD'; Select = '((?<=for\s")(.*)(?<="))'}; #Added for Outlook Stig - JJS
     #Nine = @{ Match = '(?<=If the value(\s*)?((for( )?)?)").*(")?((?=is.*R)|(?=does not exist))'; Select = '((?<=for\s).*)' };
     }

$global:SingleLineRegistryValueType +=
     [ordered]@{
     Eight = @{ Select = '((?<=If the\s)(.*)(?<=DWORD))'}; #Added for Outlook Stig - JJS
    }

$global:SingleLineRegistryValueData +=
     [ordered]@{
     Six = @{ Match = 'If the value PublishCalendarDetailsPolicy'; Select = '((?<=is\s)(.*)(?=\sor))'} #Added for Outlook Stig - JJS
    }
