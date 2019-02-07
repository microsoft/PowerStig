# Windows Server 2012 R2 Domain Controller formatting updates

xccdf files are formated to ease reading the raw content using the following VS Code extension

https://marketplace.visualstudio.com/items?itemName=DotJoshJohnson.xml

Updates are listed in the following format:

RuleId::LineNumber(ZeroIndex)::Updated line

## V2R15

* V-2377::8::If the value for "Maximum lifetime for service ticket" is "0" or greater than "600" minutes, this is a finding.
* V-2378::8::If the value for "Maximum lifetime for user ticket" is "0" or greater than "10" hours, this is a finding.
* V-2379::8::If the "Maximum lifetime for user ticket renewal" is greater than "7" days, this is a finding.
* V-2380::8::If the "Maximum tolerance for computer clock synchronization" is greater than "5" minutes, this is a finding.
* V-36707::8::Value:  1 (Give user a warning…) Or 2 (Require approval…)

## V2R14

* V-2377::8::If the value for "Maximum lifetime for service ticket" is "0" or greater than "600" minutes, this is a finding.
* V-2378::8::If the value for "Maximum lifetime for user ticket" is "0" or greater than "10" hours, this is a finding.
* V-2379::8::If the "Maximum lifetime for user ticket renewal" is greater than "7" days, this is a finding.
* V-2380::8::If the "Maximum tolerance for computer clock synchronization" is greater than "5" minutes, this is a finding.
* V-36707::8::Value:  1 (Give user a warning…) Or 2 (Require approval…)

## V2R13

* V-2377::8::If the value for "Maximum lifetime for service ticket" is "0" or greater than "600" minutes, this is a finding.
* V-2378::8::If the value for "Maximum lifetime for user ticket" is "0" or greater than "10" hours, this is a finding.
* V-2379::8::If the "Maximum lifetime for user ticket renewal" is greater than "7" days, this is a finding.
* V-2380::8::If the "Maximum tolerance for computer clock synchronization" is greater than "5" minutes, this is a finding.
* V-36707::8::Value:  1 (Give user a warning…) Or 2 (Require approval…)

## V2R12

* V-2377::8::If the value for "Maximum lifetime for service ticket" is "0" or greater than "600" minutes, this is a finding.
* V-2378::8::If the value for "Maximum lifetime for user ticket" is "0" or greater than "10" hours, this is a finding.
* V-2379::8::If the "Maximum lifetime for user ticket renewal" is greater than "7" days, this is a finding.
* V-2380::8::If the "Maximum tolerance for computer clock synchronization" is greater than "5" minutes, this is a finding.
