# Windows Server 2016 formatting updates

xccdf files are formated to ease reading the raw content using the following VS Code extension

https://marketplace.visualstudio.com/items?itemName=DotJoshJohnson.xml

Updates are listed in the following format:

RuleId::LineNumber(ZeroIndex)::Updated line

## V1R4

* V-73509::9::Value: RequireMutualAuthentication=1,RequireIntegrity=1
* V-73509::13::Value: RequireMutualAuthentication=1,RequireIntegrity=1
* V-73521::12::Value: 0x00000001 (1) or 0x00000003 (3) or 0x00000008 (8) (or if the Value Name does not exist)
* V-73591::3::Registry Path: \SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\

## V1R6

* V-73509::9::Value: RequireMutualAuthentication=1,RequireIntegrity=1
* V-73509::13::Value: RequireMutualAuthentication=1,RequireIntegrity=1
* V-73521::12::Value: 0x00000001 (1) or 0x00000003 (3) or 0x00000008 (8) (or if the Value Name does not exist)
* V-73591::3::Registry Path: \SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\
* V-73551::8::Value: 0x00000000 (0) (Security) or 0x00000001 (1) (Basic)
* V-73711::8::Value: 0x00000001 (1) (Prompt for credentials on the secure desktop) or 0x00000002 (2) (Prompt for consent on the secure desktop)
* V-73251::13::C:\Program Files and C:\Program Files (x86)
* V-73253::13::C:\Windows
