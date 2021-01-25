<#
    Markdown table template used for each technology STIG
    READ THIS! Markdown formatting syntax for line breaks requires two or more trailing whitespaces.
    In order to ensure that the whitespaces remain, add the following to VSCode settings.json:

    "[markdown]": {
        "files.trimTrailingWhitespace": false
    }

    This will ensure that the trailing whitespaces remain in the resulting StigCoverage.md file
    when pushed to the PowerSTIG.wiki.
#>

@{
    markdownSummaryHeader = @'
# PowerSTIG Technology Coverage : Module Version {0}

A Summary of Technology Coverage for **PowerSTIG** is listed below, for more detailed rule coverage, follow the technology specific link:
'@
    markdownSummaryBody = @'
## [{0}, Version {1}]({2})

**Title:** {3}{18}{18}
**Version:** {4}{18}{18}
**Release:** {5}{18}{18}
**FileName:** {6}{18}{18}
**Created:** {7}{18}{18}
**Description:** {8}{18}{18}
**Total Stig Rule Coverage:** **{9}** of **{10}** rules are automated; **{11}%**

* **High (CAT I):** **{12}** of **{13}** rules are automated
* **Medium (CAT II):** **{14}** of **{15}** rules are automated
* **Low (CAT III):** **{16}** of **{17}** rules are automated
'@
    markdownRuleTableHeader = @'
## Automated Rules

| StigRuleId | Severity | RuleType | DscResource | DuplicateOf |
| :---- | :---- | :---- | :---- | :---- |
'@
    markdownDocumentRuleTableHeader = @'
## Document / Manual Rules (Not Automated)

| StigRuleId | Severity | RuleType |
| :---- | :---- | :---- |
'@
    markdownRuleDetail         = '| {0} | {1} | {2} | {3} | {4} |'
    markdownDocumentRuleDetail = '| {0} | {1} | {2} |'
    markdownRuleLink           = 'https://github.com/Microsoft/PowerStig/wiki/{0}'
    markdownSidebarToc         = '  * [{0}][{1}]'
    markdownSidebarHyperLink   = '[{0}]: {1}'
}
