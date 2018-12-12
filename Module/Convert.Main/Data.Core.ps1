# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
$global:SingleLineRegistryPath += 
     [ordered]@{
        Office2 = [ordered]@{
            Match = 'outlook\\security'; 
            Select   = '((HKLM|HKCU).*\\security)' 
        };
        Criteria = [ordered]@{ 
                        Contains = 'Criteria:'; 
                        After    = [ordered]@{ 
                                        Match  = '((HKLM|HKCU).*(?=Criteria:))';
                                        Select = '((HKLM|HKCU).*(?=Criteria:))'; 
                                        
                                    };
                        Before   = [ordered]@{
                                        Match = 'Criteria:.*(HKLM|HKCU)'
                                        Select = '((HKLM|HKCU).*(?=\sis))'
                                    } 
                    };

        Root     = [ordered]@{ 
                    Match    = '(HKCU|HKLM|HKEY_LOCAL_MACHINE)\\'; 
                    Select   = '((HKLM|HKCU|HKEY_LOCAL_MACHINE|HKEY_CURRENT_USER).*)' 
                };
        
        Verify = [ordered]@{ 
                    Contains = 'Verify'; 
                    Select   = '((HKLM|HKCU).*(?=Verify))'
              };
    }

$global:SingleLineRegistryValueName += 
     [ordered]@{
     One = @{ Select = '(?<=If the value(\s*)?((for( )?)?)").*(")?((?=is.*R)|(?=does not exist))' };
     Two = [ordered]@{ Match = 'If the.+(registry key does not exist)'; Select = '"[\s\S]*?"' };
     Three = @{ Select = '(?<=If the value of\s")(.*)(?="\s.*R)|(?=does not exist)' };
     Four = @{ Match = 'a value of between'; Select = '((?<=gs\\)(.*)(?<=Len))' };
     Five = @{ Select = '((?<=If the value\s)(.*)(?=is\sR))' };
     Six = [ordered]@{ Match = 'the policy value'; Select = '(?<=")(.*)(?="\sis)' };
     Seven = @{ Select = '((?<=for\s).*)' };
     Eight = @{ Select = '(?<=filevalidation\\).*(?=\sis\sset\sto)' }
     }

$global:SingleLineRegistryValueType += 
     [ordered]@{
     One = @{ Select = '(?<={0}(") is not).*=' }; #'(?<={0}(\"")? is not ).*=' #$([regex]::escape($myString))
     Two = @{ Select =  '({0}"?\sis (?!not))(.*=)'; Group = 2 }; #'(?<={0}(")\sis).*='}; #'(?<={0}(\"")?\s+is ).*=' }; 
     #'(?<={0}(\"")?\s+is ).*=' };
     Three = @{ Select = '(?<=Verify\sa).*(?=value\sof)'};
     Four = @{ Select = 'registry key exists and the([\s\S]*?)value'; Group = 1 };
     Five = @{ Select = '(?<={0}" is set to ).*"'};
     Six = @{ Select = '((hkcu|hklm).*\sis\s(.*)=)'; Group = 3 };
     #Seven = @{ Select = 'does not exist, this is not a finding'; Return = 'Does Not Exist'}
     }

$global:SingleLineRegistryValueData += 
     [ordered]@{
     One = @{ Select = '(?<={0})(\s*)?=.*(?=(,|\())'};   #'(?<={0}(\s*)?=).*(?=(,|\())' };
     Two = @{ Select = '((?<=value\sof).*(?=for))' };
     Three = @{ Select = '((?<=set\sto).*(?=\(true\)))' };
     Four = @{ Select = "((?<=is\sset\sto\s)(`'|`")).*(?=(`'|`"))" };
     Five = @{ Select = "(?<={0}\s=).*"}
     }
