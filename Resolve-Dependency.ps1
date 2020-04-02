[CmdletBinding()]
param
(

    [Parameter()]
    [String]
    $DependencyFile = 'RequiredModules.psd1',

    [Parameter()]
    [String]
    # Path for PSDepend to be bootstrapped and save other dependencies.
    # Can also be CurrentUser or AllUsers if you wish to install the modules in such scope
    # Default to $PWD.Path/output/modules
    $PSDependTarget = (Join-Path $PSScriptRoot './output/RequiredModules'),

    [Parameter()]
    [uri]
    # URI to use for Proxy when attempting to Bootstrap PackageProvider & PowerShellGet
    $Proxy,

    [Parameter()]
    # Credential to contact the Proxy when provided
    [PSCredential]$ProxyCredential,

    [Parameter()]
    [ValidateSet('CurrentUser', 'AllUsers')]
    [String]
    # Scope to bootstrap the PackageProvider and PSGet if not available
    $Scope = 'CurrentUser',

    [Parameter()]
    [String]
    # Gallery to use when bootstrapping PackageProvider, PSGet and when calling PSDepend (can be overridden in Dependency files)
    $Gallery = 'PSGallery',

    [Parameter()]
    [PSCredential]
    # Credentials to use with the Gallery specified above
    $GalleryCredential,


    [Parameter()]
    [switch]
    # Allow you to use a locally installed version of PowerShellGet older than 1.6.0 (not recommended, default to $False)
    $AllowOldPowerShellGetModule,

    [Parameter()]
    [String]
    # Allow you to specify a minimum version fo PSDepend, if you're after specific features.
    $MinimumPSDependVersion,

    [Parameter()]
    [Switch]
    $AllowPrerelease,

    [Parameter()]
    [Switch]
    $WithYAML
)

# Load Defaults for parameters values from Resolve-Dependency.psd1 if not provided as parameter
try
{
    Write-Verbose -Message "Importing Bootstrap default parameters from '$PSScriptRoot/Resolve-Dependency.psd1'."
    $ResolveDependencyDefaults = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot '.\Resolve-Dependency.psd1' -Resolve -ErrorAction Stop)
    $ParameterToDefault = $MyInvocation.MyCommand.ParameterSets.Where{ $_.Name -eq $PSCmdlet.ParameterSetName }.Parameters.Keys
    if ($ParameterToDefault.Count -eq 0)
    {
        $ParameterToDefault = $MyInvocation.MyCommand.Parameters.Keys
    }
    # Set the parameters available in the Parameter Set, or it's not possible to choose yet, so all parameters are an option
    foreach ($ParamName in $ParameterToDefault)
    {
        if (-Not $PSBoundParameters.Keys.Contains($ParamName) -and $ResolveDependencyDefaults.ContainsKey($ParamName))
        {
            Write-Verbose -Message "Setting $ParamName with $($ResolveDependencyDefaults[$ParamName])"
            try
            {
                $variableValue = $ResolveDependencyDefaults[$ParamName]
                if ($variableValue -is [string])
                {
                    $variableValue = $ExecutionContext.InvokeCommand.ExpandString($variableValue)
                }
                $PSBoundParameters.Add($ParamName, $variableValue)
                Set-Variable -Name $ParamName -value $variableValue -Force -ErrorAction SilentlyContinue
            }
            catch
            {
                Write-Verbose -Message "Error adding default for $ParamName : $($_.Exception.Message)"
            }
        }
    }
}
catch
{
    Write-Warning -Message "Error attempting to import Bootstrap's default parameters from $(Join-Path $PSScriptRoot '.\Resolve-Dependency.psd1'): $($_.Exception.Message)."
}

Write-Progress -Activity "Bootstrap:" -PercentComplete 0 -CurrentOperation "NuGet Bootstrap"

if (!(Get-PackageProvider -Name NuGet -ForceBootstrap -ErrorAction SilentlyContinue))
{
    $providerBootstrapParams = @{
        Name           = 'nuget'
        force          = $true
        ForceBootstrap = $true
        ErrorAction    = 'Stop'
    }

    switch ($PSBoundParameters.Keys)
    {
        'Proxy'
        {
            $providerBootstrapParams.Add('Proxy', $Proxy)
        }
        'ProxyCredential'
        {
            $providerBootstrapParams.Add('ProxyCredential', $ProxyCredential)
        }
        'Scope'
        {
            $providerBootstrapParams.Add('Scope', $Scope)
        }
    }

    if ($AllowPrerelease)
    {
        $providerBootstrapParams.Add('AllowPrerelease', $true)
    }

    Write-Information "Bootstrap: Installing NuGet Package Provider from the web (Make sure Microsoft addresses/ranges are allowed)"
    $null = Install-PackageProvider @providerBootstrapParams
    $latestNuGetVersion = (Get-PackageProvider -Name NuGet -ListAvailable | Select-Object -First 1).Version.ToString()
    Write-Information "Bootstrap: Importing NuGet Package Provider version $latestNuGetVersion to current session."
    $Null = Import-PackageProvider -Name NuGet -RequiredVersion $latestNuGetVersion -Force
}

Write-Progress -Activity "Bootstrap:" -PercentComplete 10 -CurrentOperation "Ensuring Gallery $Gallery is trusted"

# Fail if the given PSGallery is not Registered
$Policy = (Get-PSRepository $Gallery -ErrorAction Stop).InstallationPolicy
Set-PSRepository -Name $Gallery -InstallationPolicy Trusted -ErrorAction Ignore
try
{
    Write-Progress -Activity "Bootstrap:" -PercentComplete 25 -CurrentOperation "Checking PowerShellGet"
    # Ensure the module is loaded and retrieve the version you have
    $PowerShellGetVersion = (Import-Module PowerShellGet -PassThru -ErrorAction SilentlyContinue).Version

    Write-Verbose "Bootstrap: The PowerShellGet version is $PowerShellGetVersion"
    # Versions below 1.6.0 are considered old, unreliable & not recommended
    if (!$PowerShellGetVersion -or ($PowerShellGetVersion -lt [System.version]'1.6.0' -and !$AllowOldPowerShellGetModule))
    {
        Write-Progress -Activity "Bootstrap:" -PercentComplete 40 -CurrentOperation "Installing newer version of PowerShellGet"
        $InstallPSGetParam = @{
            Name               = 'PowerShellGet'
            Force              = $True
            SkipPublisherCheck = $true
            AllowClobber       = $true
            Scope              = $Scope
            Repository         = $Gallery
        }

        switch ($PSBoundParameters.Keys)
        {
            'Proxy'
            {
                $InstallPSGetParam.Add('Proxy', $Proxy)
            }
            'ProxyCredential'
            {
                $InstallPSGetParam.Add('ProxyCredential', $ProxyCredential)
            }
            'GalleryCredential'
            {
                $InstallPSGetParam.Add('Credential', $GalleryCredential)
            }
        }

        Install-Module @InstallPSGetParam
        Remove-Module PowerShellGet -force -ErrorAction SilentlyContinue
        Import-Module PowerShellGet -Force
        $NewLoadedVersion = (Get-Module PowerShellGet).Version.ToString()
        Write-Information "Bootstrap: PowerShellGet version loaded is $NewLoadedVersion"
        Write-Progress -Activity "Bootstrap:" -PercentComplete 60 -CurrentOperation "Installing newer version of PowerShellGet"
    }

    # Try to import the PSDepend module from the available modules
    try
    {
        $ImportPSDependParam = @{
            Name        = 'PSDepend'
            ErrorAction = 'Stop'
            Force       = $true
        }

        if ($MinimumPSDependVersion)
        {
            $ImportPSDependParam.add('MinimumVersion', $MinimumPSDependVersion)
        }
        $null = Import-Module @ImportPSDependParam
    }
    catch
    {
        # PSDepend module not found, installing or saving it
        if ($PSDependTarget -in 'CurrentUser', 'AllUsers')
        {
            Write-Debug "PSDepend module not found. Attempting to install from Gallery $Gallery"
            Write-Warning "Installing PSDepend in $PSDependTarget Scope"
            $InstallPSDependParam = @{
                Name               = 'PSDepend'
                Repository         = $Gallery
                Force              = $true
                Scope              = $PSDependTarget
                SkipPublisherCheck = $true
                AllowClobber       = $true
            }

            if ($MinimumPSDependVersion)
            {
                $InstallPSDependParam.add('MinimumVersion', $MinimumPSDependVersion)
            }

            Write-Progress -Activity "Bootstrap:" -PercentComplete 75 -CurrentOperation "Installing PSDepend from $Gallery"
            Install-Module @InstallPSDependParam
        }
        else
        {
            Write-Debug "PSDepend module not found. Attempting to Save from Gallery $Gallery to $PSDependTarget"
            $SaveModuleParam = @{
                Name       = 'PSDepend'
                Repository = $Gallery
                Path       = $PSDependTarget
            }

            if ($MinimumPSDependVersion)
            {
                $SaveModuleParam.add('MinimumVersion', $MinimumPSDependVersion)
            }

            Write-Progress -Activity "Bootstrap:" -PercentComplete 75 -CurrentOperation "Saving & Importing PSDepend from $Gallery to $Scope"
            Save-Module @SaveModuleParam
        }
    }
    finally
    {
        Write-Progress -Activity "Bootstrap:" -PercentComplete 100 -CurrentOperation "Loading PSDepend"
        # We should have successfully bootstrapped PSDepend. Fail if not available
        Import-Module PSDepend -ErrorAction Stop
    }

    if ($WithYAML)
    {
        if (-Not (Get-Module -ListAvailable -Name 'PowerShell-Yaml'))
        {
            Write-Verbose "PowerShell-Yaml module not found. Attempting to Save from Gallery $Gallery to $PSDependTarget"
            $SaveModuleParam = @{
                Name       = 'PowerShell-Yaml'
                Repository = $Gallery
                Path       = $PSDependTarget
            }

            Save-Module @SaveModuleParam
            Import-Module "PowerShell-Yaml" -ErrorAction Stop
        }
        else
        {
            Write-Verbose "PowerShell-Yaml is already available"
        }
    }

    Write-Progress -Activity "PSDepend:" -PercentComplete 0 -CurrentOperation "Restoring Build Dependencies"
    if (Test-Path $DependencyFile)
    {
        $PSDependParams = @{
            Force = $true
            Path  = $DependencyFile
        }

        # TODO: Handle when the Dependency file is in YAML, and -WithYAML is specified
        Invoke-PSDepend @PSDependParams
    }
    Write-Progress -Activity "PSDepend:" -PercentComplete 100 -CurrentOperation "Dependencies restored" -Completed
}
finally
{
    # Reverting the Installation Policy for the given gallery
    Set-PSRepository -Name $Gallery -InstallationPolicy $Policy
    Write-Verbose "Project Bootstrapped, returning to Invoke-Build"
}
