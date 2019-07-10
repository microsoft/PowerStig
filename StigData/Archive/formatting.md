# PowerSTIG Archive log file

* I have talked a little bit about starting to modify the xccdf files to fix minor issues in the content the DISA provides.
* The initial idea was to manually update the xccdf and keep a record of the change in a markdown file. ID::OldText::NewText
* I realized that this is not a great solution, due to not being 100% sure what the original text was.
* Let's automate

## Challenge

* It feels like there is a conspiracy at DISA to make PowerSTIG parser a PIA to maintain.
* I keep seeing Issues opened to update the parser for the latest STIG X
* No easy way to fix Spelling \ Formatting issues

## Purposed solution

* Take the original idea and automate it now before we make a bunch of changes that we have to undo later.
* The change log is now an active file that is used during the parsing process.

## How it works

1. The code looks for a .log file with the same full path as the xccdf.
1. Each line is in the following format ID::OldText::NewText
    1. Multiple entries per rule are supported
    1. The asterisk "*" can be used to replace everything in the check-content
1. The log content is converted into a hashtable
1. Before a rule is processed, the check-content string is updated using a replace OldText > NewText.
1. The rule is parsed and returned
1. The RawString is then updated to undo the log file change NewText > OldText.

This allows us to inject the rule intent without having to dig into the xml or update the parser.
We have most of the general patterns ironed out and now we are just dealing with random formatting\ spelling charges.
We need to take the time to determine when the change needs to be made, because we don't necessarily want to end up with a log file entry for each rule either.
