$rules = (Get-RuleClassData -StigData $StigData -Name FileContentRule).Where({ $PSItem.dscresource -eq 'ReplaceText' })

# assert FireFox install directory

if (-not(Test-Path -Path $InstallDirectory))
{
    throw "$InstallDirectory not found"
}

ReplaceText GeneralConfigFileName
{
    Path        = "$InstallDirectory\defaults\pref\autoconfig.js"
    Search      = 'pref\("general.config.filename", (.*)\);'
    Type        = 'Text'
    Text        = 'pref("general.config.filename", "firefox.cfg");'
    AllowAppend = $true
}

ReplaceText DoNotObscureFile
{
    Path        = "$InstallDirectory\defaults\pref\autoconfig.js"
    Search      = 'pref\("general.config.obscure_value", (.*)\);'
    Type        = 'Text'
    Text        = 'pref("general.config.obscure_value", 0);'
    AllowAppend = $true
}

<#
    The second file to create is called firefox.cfg and it is placed at the top level of the Firefox directory. It should always begin with a commented line, such as: 
    // IMPORTANT: Start your code on the 2nd line
#>
ReplaceText BeginFileWithComment
{
    Path        = "$InstallDirectory\firefox.cfg"
    Search      = '// FireFox preference file'
    Type        = 'Text'
    Text        = '// FireFox preference file'
    AllowAppend = $true
}

foreach ( $rule in $rules )
{
    ReplaceText (Get-ResourceTitle -Rule $rule)
    {
        Path        = "$InstallDirectory\FireFox.cfg"
        Search      = 'lockPref\("{0}", (.*)\);' -f $rule.Key
        Type        = 'Text'
        Text        = 'lockPref("{0}", {1});' -f $rule.Key, (Format-FireFoxPreference -Value $rule.Value)
        AllowAppend = $true
    }
}
