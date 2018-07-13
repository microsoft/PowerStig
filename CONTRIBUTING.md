# Contributing to PowerStig

Welcome to PowerStig!
We're thrilled that you'd like to contribute!

There are a few different ways you can contribute:

* [Submit an issue](#submitting-an-issue)
* [Fix an issue](#fixing-an-issue)
* [Write documentation](#writing-documentation)
* [Review pull requests](#reviewing-pull-requests)

If you're just starting out with GitHub, start by reading the excellent [guide to getting started with GitHub](https://github.com/PowerShell/DscResources/blob/master/GettingStartedWithGitHub.md) over on the DscResources repository.

If you have any questions or concerns, feel free to reach out to [@athaynes](https://github.com/athaynes), [@jcwalker](https://github.com/jcwalker), or [@regedit32](https://github.com/regedit32) for help.

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Submitting an Issue

Submitting an issue to PowerStig is easy!

Here are the steps:

1. Find the correct repository to submit your issue to.
2. Make sure the issue is not open already.
3. Open a new issue.
4. Fill in the issue title.
5. Fill in the issue description.
6. Submit the issue.

### Find the Correct Repository

| Issue Topic | Where to Submit |
|-------------|-----------------|
| <ul><li> PowerStig overall </li><li> Issues that span multiple PowerStig projects or repos </li><li> PowerStig processes </li></ul> | PowerStig (this repository) |
| <ul><li> Common tests </li><li> Schemas </li></ul> | [PowerStig.Tests](https://github.com/Microsoft/PowerStig.Tests)
| <ul><li> Bugs, feature requests, enhancements to a specific module | The repository of the module |

### Open an Issue

Once you are in the correct repository to submit your issue, go to the Issues tab.
![GitHubIssuesTab](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubIssuesTab.png)

**Ensure that the issue you are about to file is not already open.**
If someone has already opened a similar issue, please leave a comment or add a GitHub reaction to the top comment to **express your interest**. You can also offer help and use the issue to coordinate your efforts in fixing the issue.

If you cannot find an issue that matches the one you are about to file, click the New Issue button on the right.
![GitHubNewIssueButton](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubNewIssueButton.png)

A new, blank issue should open up.
![GitHubBlankIssue](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubBlankIssue.PNG)

### Fill in Issue Title

The issue title should be a brief summary of your issue in one sentence.

If you would like to submit an issue that would include a breaking change, please also refer to our [Breaking Changes](#breaking-changes) section below.

### Fill in Issue Description

The issue description should contain a **detailed** report of the issue you are submitting.
If you are submitting a bug, please include any error messages or stack traces caused by the problem.

Please reference any related issues or pull requests by a pound sign followed by the issue or pull request number (e.g. #11, #72). GitHub will automatically link the number to the corresponding issue or pull request. You can also link to pull requests and issues in other repositories by including the repository owner and name before the issue number.
Like this:

```cmd
<owner name>/<repository name>#<number of PR/issue>
```

So to link to issue #23 in the PowerStigDsc repository which is owned by Microsoft:

```cmd
Microsoft/PowerStigDsc#23
```

Please also tag any GitHub users you would like to notice this issue. You can tag someone on GitHub with the @ symbol followed by their username.(e.g. @athaynes)

### Submit an Issue

Once you have filled out the issue title and description, click the submit button at the bottom of the issue.
![GitHubIssueSubmitButton](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubIssueSubmitButton.png)

## Fixing an Issue

Here's the general process of fixing an issue in PowerStig:

1. Pick out the issue you'd like to work on.
1. Create a fork of the repository that contains the issue.
1. Clone your fork to your machine.
1. Create a working branch where you can store your updates to the code.
1. Make changes in your working branch to solve the issue.
1. Write tests to ensure that the issue is fixed.
1. Update the 'Unreleased' section of the module's release notes to include your changes.
1. Submit a pull request to the dev branch of the official repository for review.
1. Make sure all tests are passing in AppVeyor for your pull request.
1. Make sure your code does not contain merge conflicts.
1. Address any comments brought up by the reviewer.

### Pick an Issue

Issues that are currently up-for-grabs are tagged with the ```help wanted``` label.

If you find an issue that you want to work on, but it does not have the ```help wanted``` label, make sure to read through the issue and ask if you can start working on it.

### Fork a Respository

A 'fork' on GitHub is your own personal copy of a repository.
GitHub's guide to forking a repository is available [here](https://help.github.com/articles/fork-a-repo/).
You will need a fork to contribute to any of the repositories in PowerStig since only the maintainers have the ability to push to the official repositories.

Once you have created your fork, you can easily access it via the URL:

```cmd
https://github.com/<your GitHub username>/<module name>
```

### Clone your Fork

You will want to clone your fork so that you can edit code locally on your machine.
GitHub's guide to cloning is available [here](https://help.github.com/articles/cloning-a-repository/).

### Create a Working Branch

We use a [git flow](http://nvie.com/posts/a-successful-git-branching-model/) model in our official repositories.

Your fork is your personal territory.
You may set it up however best suits your workflow, but we recommend that you set up a working branch separate from the default dev branch.
Creating a working branch separate from the default dev branch will allow you to create other working branches off of dev later while your original working branch is still open for code reviews.
Limiting your current working branch to a single issue will also both streamline the code review and reduce the possibility of merge conflicts.

The Git guide to branching is available [here](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging).

### Make Code Changes

When writing code for any of the modules in PowerStig, please follow PowerStig [Style Guidelines](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md) and [Best Practices](https://github.com/PowerShell/DscResources/blob/master/BestPractices.md).
These guidelines are from the PowerShell/DscResources projects and may not always reflect the same PowerShell style as other projects.
Code reviewers will expect you to follow these guidelines and may ask you to change your code for consistency.

If you need help committing and pushing your code to your fork, please refer to our [guide to getting started with GitHub](https://github.com/PowerShell/DscResources/blob/master/GettingStartedWithGitHub.md).

Pay attention to any new code merged into the dev branch of the official repository. If this occurs, you will need to pick-up these changes in your fork using the rebase instructions in our [guide to getting started with GitHub](https://github.com/PowerShell/DscResources/blob/master/GettingStartedWithGitHub.md).

If you are making a breaking change, please make sure to read the [Breaking Changes section](#breaking-changes) below.

### Write Tests

All modules in PowerStig should have tests written using [Pester](https://github.com/pester/Pester) included in the Tests folder.
You are required to provide adequate test coverage for the code you change.

Please refer to our [testing guidelines](TestsGuidelines.md) for information on how to write tests for PowerStig.
Our test templates and guidelines are currently under construction.
Use them with caution as they may be changed soon.

Tests should currently be structured like so:

* Root folder of module
  * Tests
    * Unit
      * Module.Tests.ps1
    * Integration
      * Module.Integration.Tests.ps1

Not all module currently have tests.
This does not mean that you do not have to write tests for your changes.
If you find that the test file for a module is missing or one of the folders in the structure outlined above is missing, please create it.
You don't have to write the full set of tests for the module if you are creating the file.
You only need to test the changes that you made to the module.

### Update the Release Notes

Release notes for each module are included in the README.md file under the root folder.
Currently unreleased changes are listed under the 'Unreleased' section under the 'Versions' header.
If this section is missing, please add it.

To update the release notes with your changes, simply add a bullet point (or more) with your changes in the **past** tense under the 'Unreleased' section.
For example:

```cmd
...
## Versions

### Unreleased
- Added the FriendlyName parameter to ConvertTo-PowerStigXml

### 1.0.0.0
...
```

If you are making a breaking change, please make sure to read the [Breaking Changes section](#breaking-changes) below.

### Submit a Pull Request

A [pull request](https://help.github.com/articles/using-pull-requests/) (PR) allows you to submit the changes you made in your fork to the official repository.

To open a pull request, go to the Pull Requests tab of either your fork or the official repository.
![GitHubPullRequestsTabInFork.png](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubPullRequestsTabInFork.png)

Click the New Pull Request button on the right:
![GitHubNewPullRequestButton.png](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubNewPullRequestButton.png)

The base is the repository and branch the pull request will be merging **into**.
The target is the repository and branch the pull request will be merging **from**.
For PowerStig, always create a pull request with the base as the **dev** branch of the official repository.
The target should be your working branch in your fork.
![Github-PR-dev.png](https://github.com/PowerShell/DscResources/blob/master/Images/Github-PR-dev.png)

Once you select the correct base and target, you can review the file and commits that will be included in the pull request by selecting the tabs below the Create Pull Requests Button:
![GitHubPullRequestFileReview.png](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubPullRequestFileReview.png)

If GitHub tells you that your branches cannot automatically be merged, you probably have merge conflicts. These should be fixed before you submit your pull request.
![GitHubPullRequestPreCreateMergeConflict.png](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubPullRequestPreCreateMergeConflict.png)

For help fixing merge conflicts see our [guide to getting started with GitHub](https://github.com/PowerShell/DscResources/blob/master/GettingStartedWithGitHub.md).

Once you are ready to submit your pull request, click the Create Pull Request button.
![GitHubCreatePullRequestButton.png](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubCreatePullRequestButton.png)

#### Pull Request Title

The title of your PR should *describe* the changes it includes in one line.
Simply putting the issue number that the PR fixes is not acceptable.
If your PR deals with *one* specific module, please prefix the title with the module name followed by a colon.
If your PR fixes an issue please do still include "(Fixes #issue number)" in the title.
For example, if a PR fixes issues number 11 and 16 which adds the Ensure parameter, the title should be something like:
"Module: Added Ensure parameter (Fixes #11, #16)".

If your pull request includes a breaking change, please refer to the [Breaking Changes](#breaking-changes) section below.

If you open a pull request with the wrong title, you can easily edit it by clicking the Edit button to the right of the title in the open pull request.

#### Pull Request Description

The description of your PR should include a detailed report of all the changes you made.
If your PR fixes an issue please include the number in the description.
Please tag anyone you would specifically like to see this PR with the @ symbol followed by their GitHub username (e.g. @athaynes).

Once you are satisfied with the title, description and file changes included, submit the pull request.

#### Contribution License Agreement (CLA)

If this is your first contribution to PowerStig, you may be asked to sign a [Contribution Licensing Agreement](https://cla.microsoft.com/) (CLA) before your changes can be reviewed:
![GitHubCLARequired.png](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubCLARequired.png)

Once you sign the CLA, the Microsoft CLA bot will automatically update the comment in your PR:
![GitHubCLASigned.png](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubCLASigned.png)

The CLA status check should also pass in your PR.
![GitHubCLAStatusCheck.png](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubCLAStatusCheck.png)

Once you have signed our CLA, you shouldn't have to do it again.
If you believe you have signed our CLA before, but the Microsoft CLA bot still
marks your PR as "CLA not signed yet", or the CLA status check does not pass,
please sign the CLA again. Sometimes the little bot makes mistakes.

### Tests in AppVeyor

PowerStig uses [AppVeyor](http://www.appveyor.com/) as a continuous integration (CI) system.

After submitting your pull request, AppVeyor will automatically run a suite of tests on your submitted changes.
Afterwards, AppVeyor will update the status of the pull request, providing at-a-glance feedback about whether your changes are passing tests or not.
![AppVeyor-Github](https://github.com/PowerShell/DscResources/blob/master/Images/AppVeyor-Github.png)

All the green checkboxes and red crosses are **clickable**.
They will bring you to the corresponding test page with details on which tests are running and why your tests may be failing.

A maintainer **will not** merge your pull request if these tests are failing, even if they have nothing to do with your changes.
If test failures are occurring that do not relate to the changes you made, you will have to submit another PR with fixes for those failures or wait until someone else does.

Any commit to the working branch that is the target of the pull request will trigger the tests to run again in AppVeyor.
If you tag a maintainer, they can also re-run your tests in AppVeyor.

The appveyor.yml file in each module repository describes the build and test sequence provided to AppVeyor.

An AppVeyor badge indicating the latest build status of the **master** and **dev** branches at the top of the README.md file of every module repository.
![AppVeyor-Badge-Green.png](https://github.com/PowerShell/DscResources/blob/master/Images/AppVeyor-Badge-Green.png)

This badge is also **clickable**.
It opens the corresponding module's AppVeyor page which shows test logs and results.
From this page you can easily navigate through the build history of the module.

#### Common Tests

There is a set of common tests for all modules located in the [DSCResource.Tests](https://github.com/PowerShell/DscResource.Tests) repository.

These tests primarily concentrate on code style, file encoding, correct module schema, and PS Script Analyzer issues.
These tests are too good not to use and too complex to duplicate and maintain separately, even if they are geared toward DSC resources.
At the end of the day, PowerShell is PowerShell, so only a few of the tests are not applicable to PowerStig.

You should run these tests before submitting a pull request.
The common DSC Resources tests are automatically downloaded into the root module folder when tests are invoked.
If this is not happening for your module, you will need to clone [DSCResource.Tests](https://github.com/PowerShell/DscResource.Tests) into the root folder of the module that you want to test.
Then simply run `Invoke-Pester` from the root folder.

Like this:
```
cd C:\MyPath\ResourceModuleFolder
git clone https://github.com/PowerShell/DscResource.Tests
Invoke-Pester
```

Please avoid adding the **DSCResource.Tests** folder to your changes.
DSCResource.Tests should be in the .gitignore file so that git will automatically ignore this folder.
If DSCResource.Tests is not in the .gitignore file, please add it.
If there is no .gitignore file for your module, instructions on how to add one are available in our [getting started with GitHub](https://github.com/PowerShell/DscResources/blob/master/GettingStartedWithGitHub.md) instructions.

The [MetaFixers](https://github.com/PowerShell/DscResource.Tests/blob/master/MetaFixers.psm1) module also in [DSCResource.Tests](https://github.com/PowerShell/DscResource.Tests) contains a few fix-helper methods such as a function to convert all tab indentations to 4 spaces and a function to fix file encodings.

### Fix Merge Conflicts

If you have merge conflicts, please use Git rebasing to fix them instead of Git merging.
An introduction to Git rebasing is available in the [getting started with GitHub](https://github.com/PowerShell/DscResources/blob/master/GettingStartedWithGitHub.md) instructions.

### Get your Code Reviewed

Anyone other than you can *review* your code, but only maintainers can *merge* your code.
If you have a specific contributor/maintainer you want to review your code, be sure to tag them in your pull request.

We don't currently have dedicated maintainers for most modules, so it may take a while for a general maintainer to get around to your pull request.
Please be patient.

## Breaking Changes

Breaking changes should first be proposed by opening an issue on the resource and outlining the needed work.
This allows the community to discuss the change before the work is done and scopes the breaks to needed areas.

Opening an issue also allows the resource owner or PowerStig Owner ([@athaynes](https://github.com/athaynes)) to tag the issue with the ```breaking change``` label.

Breaking changes may include:

* Adding a new mandatory parameter
* Changing an existing parameter
* Removing an existing parameter
* Fundamentally changing an existing functionality of a resource

Once a PR is ready with the breaking change please include the following:

1. At least one of the bullet points in your addition to the updated release notes starts with 'BREAKING CHANGE:'
1. The title of the PR that includes your breaking change starts with 'BREAKING CHANGE:'

## Writing Documentation

One of the easiest ways to contribute to a PowerShell project is to write and edit documentation.
All documentation in PowerStig uses [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/) (GFM).
See the [section below](#github-flavored-markdown) for more details.

If you want to contribute new documentation, first check for existing issues to make sure you're not duplicating efforts.
If no one seems to be working on what you have planned:

1. Open a new issue to tell others about the documentation change/addition you'd like to make.
1. Create a fork of the repository you would like the documentation to be added to.
1. Edit or add the Markdown file (.md) you would like changed/added. To edit an existing file in the GitHub editor, simply navigate to it in GitHub and click the Edit button.
1. When you're ready to contribute your documentation, [submit a pull request](#submit-a-pull-request) to the official repository.

### GitHub Flavored Markdown

If you are looking for a good editor, try:

* The web interface GitHub provides for .md files
* [Markdown Pad](http://markdownpad.com/)
* [VS Code](https://code.visualstudio.com/) with the [MarkdownLint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) extension

A great guide to Github Flavored Markdown is available [here](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).

## Reviewing Pull Requests

Though only maintainers can *merge* a pull request, anyone from the community can *review* a pull request.
Maintainers will still take a quick look at code before merging it, but reviews by community members often help pull requests get merged much faster as there are very few maintainers and a lot of pull requests to review.

**Pull requests should not be reviewed while tests from AppVeyor are failing.**
If you are confused why tests in AppVeyor are failing, tag a maintainer or ask the community for help.

All modules in PowerStig should be linked to [Reviewable](https://reviewable.io), a code review tool.
Reviewable adds a purple button to the top comment of every pull request.
![GitHubReviewableButton](https://github.com/PowerShell/DscResources/blob/master/Images/GitHubReviewableButton.png)
This button is **clickable**.
It will take you to a code review of all the changes in that pull request.

If the purple Reviewable button does not appear, you can also go [here](https://reviewable.io/reviews) and paste the URL of the pull request you would like to review into this box towards the bottom of the page:
![ReviewablePullRequestPasteBox](https://github.com/PowerShell/DscResources/blob/master/Images/ReviewablePullRequestPasteBox.png)

If a pull request contains a lot of changed files, Reviewable may collapse them and show you only one file at a time. If this happens, you can navigate to other files in the pull request by clicking the purple reviewable icon at the top of the page:
![ReviewableFilePicker](https://github.com/PowerShell/DscResources/blob/master/Images/ReviewableFilePicker.png)

### Making Review Comments

You can make a comment in Reviewable either in the top discussion section (for general/overall comments) or you can click on a line of code to make a comment at that line.
Each comment you make will be saved as a draft so that you can continue making comments until you are ready to publish all of them at once. Publishing is discussed in the [Publish Review Changes](#publish-review-changes) section below.
If you want to delete a comment draft at a line of code, click the tiny trash icon at the bottom of the comment.

Some things to pay attention to while reviewing:

* Does the code logic make sense?
* Does the code structure make sense?
* Does this make the resource better?
* Is the code easy to read?
* Do all variables, parameters, and functions have **descriptive** names? (e.g. no $params, $args, $i, $a, etc.)
* Does every function have a help comment?
* Does the code follow PowerStig [Style Guidelines](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md) and [Best Practices](https://github.com/PowerShell/DscResources/blob/master/BestPractices.md)?
* Has the author included test coverage for their changes?
* Has the author updated the Unreleased section of the README with their changes?

### Resolving Review Discussions

When the author replies or makes the changes you requested and you are **satisfied** with the changes/reply, you will need to resolve the discussion. You can do this in one of two ways:

1. Click the Acknowledge button on the comment ![ReviewableAcknowledgeButton](https://github.com/PowerShell/DscResources/blob/master/Images/ReviewableAcknowledgeButton.png)

1. Click the small circle in the bottom right of the comment and select 'Satisfied'. ![ReviewableDiscussionStatusCircle](https://github.com/PowerShell/DscResources/blob/master/Images/ReviewableDiscussionStatusCircle.png)
 ![ReviewableDiscussionSatisfied](https://github.com/PowerShell/DscResources/blob/master/Images/ReviewableDiscussionSatisfied.png)

### Marking Files as Reviewed

To mark an entire file as reviewed, click the little eye button next to the file name at the top of the file so that it turns green.
![ReviewableFileReviewButtonRed](https://github.com/PowerShell/DscResources/blob/master/Images/ReviewableFileReviewButtonRed.png)
![ReviewableFileReviewButtonGreen](https://github.com/PowerShell/DscResources/blob/master/Images/ReviewableFileReviewButtonGreen.png)

### Approving a Pull Request

Please mark all files and discussions as resolved before you approve the entire pull request.

To approve the pull request, you can click the LGTM (looks good to me) button in the main discussion at the top of the code review in Reviewable:
![ReviewableLGTMButton](https://github.com/PowerShell/DscResources/blob/master/Images/ReviewableLGTMButton.png)
Or you can simply comment on the pull request on GitHub "Looks good to me" or a thumbs up.

### Publishing Review Changes

To push your comments and files marked as reviewed to the pull request on GitHub, you will need to publish your changes.
This can be done two different ways:

1. (RECOMMENDED) Click the large green Publish button at the top of the page:
  ![ReviewablePublishButton](https://github.com/PowerShell/DscResources/blob/master/Images/ReviewablePublishButton.png)
  This will publish all your changes at once and submit them as one comment to the pull request on GitHub.
1. (NOT RECOMMENDED) Click the small publish button on a comment.
  This will publish only that one comment as its own separate comment on Github.
  Please do not publish this way as it will often send a separate email for each comment to whoever is watching the pull request on GitHub.
  This method also will **not** publish the files you have marked as reviewed with the little eye button.
