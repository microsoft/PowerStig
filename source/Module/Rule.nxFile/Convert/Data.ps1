# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    This is used to centralize the regEx patterns, note that the backslashes are
    escaped, a single "\s" would be represented as "\\s"
#>
data regularExpression
{
    ConvertFrom-StringData -StringData @'
    nxFileContents        = #\\s+(?:grep|more).*\\s+(?<filePath>\\/[\\w.\\/-]*\\/[\\w.\\/-]*).*\\n(?<setting>.*\\n|.*\\n.*\\n|.*\\n.*\\n.*\\n|.*\\n.*\\n.*\\n.*\\n|.*\\n.*\\n.*\\n.*\\n.*\\n)If.*this is a finding
    nxFileContentsExclude = The result must contain the following line:|If\\s+.*commented\\s+(?:out|line).*|#\\s+cat\\s+/etc/redhat-release
    nxFileDestinationPath = #\\s+(?:grep|more).*\\s+(?<filePath>\\/[\\w.\\/-]*\\/[\\w.\\/-]*)
    nxFileFooterDetection = ^If\\s+.*$
'@
}
