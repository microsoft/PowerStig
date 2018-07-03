# Sample XCCDF

The Sample xccdf base content is designed to be reusable across all unit and integration tests using 
PowerShell composite formatting. 

## Index 
The samplexccdf contains 4 indexes that you can inject data into for testing. If any of these fields 
are not applicable to your tests, then simply pass in an empty string. Since these are indexed, the 
order is important.  

* 0 - The STIG Title
* 1 - release-info
* 2 - version
* 3 - groups
  If you do not want to provide the contents of the group element, you can use the sample group 


## How to use the content in your tests that use the benchmark element.

  # Import the base benchmark xml string data.
    $BaseXccdfContent = Get-Content -Path "$PSScriptRoot\..\..\..\sampleXccdf.xml.txt"
  
  # Create a test drive File
    $TestFile = "TestDrive:\TextData.xml"

  # Inject the data you need for your tests using the index above 
    $BaseXccdfContent -f $title.key,'','','' | Out-File $TestFile


# How to use the content in your tests that use the group elements.

  # Import the base benchmark xml string data.
    $BaseXccdfContent = Get-Content -Path "$PSScriptRoot\..\..\..\sampleXccdf.xml.txt"
  
  # Create a test drive File
    $TestFile = "TestDrive:\TextData.xml"

  # Create a sample group that structured like your test target
    $group = '
      <Group id="V-1">
      <title>Rule Title</title>
      <Rule id="SV-1234r1_rule" severity="high" weight="10.0">
      <check system="C-1234r2_chk">
      <check-content>The check content you want to test goes here. 
      </check-content>
      </check>
      </Rule>
      </Group>
    '
  # Inject the data you need for your tests using the index above 
    $BaseXccdfContent -f $title.key,'','',$group | Out-File $TestFile
