# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    This is used to centralize the regEx patterns, note that the backslashes are
    escaped, a single "\s" would be represented as "\\s"
#>
data regularExpression
{
    ConvertFrom-StringData -StringData @'
        nxFileLineContainsLineStart     = (Modify|Edit|Add).*
        nxFileLineContainsLineStop      = (Edit\\/modify|Add the following|Restart the \\w* service|If the.*service|Note:|In order for).*
        nxFileLineFilePath              = #.*\\s(?<filePath>\\/[\\w.\\/-]*\\/[\\w.\\/-]*)
        nxFileLineDoesNotContainPattern = (Edit|Edit\\/modify|Add)(,|)\\s(the|or|)\\s(following|modify|edit|update).*(".*")\\s*(|file.*|parameter|\\(.*\\)|.*situations|script):
'@
}
