# Windows Server 2012 R2 Member Server formatting updates

xccdf files are formated to ease reading the raw content using the following VS Code extension

https://marketplace.visualstudio.com/items?itemName=DotJoshJohnson.xml

Updates are listed in the following format:

RuleId::LineNumber(ZeroIndex)::Updated line

Example:

V-2377::8::If the value for "Maximum lifetime for service ticket" is "0" or greater than "600" minutes, this is a finding.

## V2R14

* V-36707::8::Value:  1 (Give user a warning…) Or 2 (Require approval…)

## V2R13

* V-36707::8::Value:  1 (Give user a warning…) Or 2 (Require approval…)

## V2R12
