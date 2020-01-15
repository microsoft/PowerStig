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

**Title:** {3}{12}{12}
**Version:** {4}{12}{12}
**Release:** {5}{12}{12}
**FileName:** {6}{12}{12}
**Created:** {7}{12}{12}
**Description:** {8}{12}{12}
**StigRuleCoverage:** **{9}** of **{10}** rules are automated; **{11}%**{12}{12}
'@
    markdownRuleTableHeader = @'
| StigRuleId | RuleType | DscResource | DuplicateOf |
| :---- | :---- | :---- | :---- |
'@
    markdownRuleDetail       = '| {0} | {1} | {2} | {3} |'
    markdownRuleLink         = 'https://github.com/Microsoft/PowerStig/wiki/{0}'
    markdownSidebarToc       = '  * [{0}][{1}]'
    markdownSidebarHyperLink = '[{0}]: {1}'
}
