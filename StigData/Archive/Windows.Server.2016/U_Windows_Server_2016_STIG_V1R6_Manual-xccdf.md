# Windows Server 2016 formatting updates

xccdf files are formated to ease reading the raw content using the following VS Code extension

https://marketplace.visualstudio.com/items?itemName=DotJoshJohnson.xml

Updates are listed in the following format:

Here is an example of how to extract the changes and auto update new files as they are released to create a new change markdown file.

```powershell
$matcher = '(?<id>V-\d+)(?:::)(?<oldText>[^::]+)(?:::)(?<newText>.+)'

$string = Get-Content -Path 'C:\Users\adamh\source\repos\PowerSTIG\PowerStig\StigData\Archive\Windows.Server.2016\U_Windows_Server_2016_STIG_V1R6_Manual-xccdf.md' -RAW

$changes = [regex]::Matches($string, $matcher)

foreach($change in $changes)
{
    $change.Groups.Item('id').value
    $change.Groups.Item('oldText').value
    $change.Groups.Item('newText').value
}
```

## Changes

V-73509::RequireMutualAuthentication=1, RequireIntegrity=1::RequireMutualAuthentication=1,RequireIntegrity=1
V-73509::RequireMutualAuthentication=1, RequireIntegrity=1::RequireMutualAuthentication=1,RequireIntegrity=1
V-73521::0x00000001 (1), 0x00000003 (3), or 0x00000008 (8)::0x00000001 (1) or 0x00000003 (3) or 0x00000008 (8)
V-73591::\SOFTWARE\ Policies::\SOFTWARE\Policies
V-73551::0x00000000 (0) (Security), 0x00000001 (1) (Basic)::0x00000000 (0) (Security) or 0x00000001 (1) (Basic)
V-73711::0x00000002 (2) (Prompt for consent on the secure desktop)
0x00000001 (1) (Prompt for credentials on the secure desktop)::Value: 0x00000001 (1) (Prompt for credentials on the secure desktop) or 0x00000002 (2) (Prompt for consent on the secure desktop)
V-73251::\Program Files and \Program Files (x86)::C:\Program Files and C:\Program Files (x86)
V-73253::\Windows::C:\Windows
