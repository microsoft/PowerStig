Import-Module UniversalDashboard.Community
. 'C:\Source\Repos\PowerStig\PowerStig.Dashboard\Data.ps1'
. 'C:\Source\Repos\PowerStig\PowerStig.Dashboard\StigDataCollection.ps1'
$stigData = Get-RuleOfType -RuleType 'All' -LatestOnly
$stigList = $stigData.StigName | Select-Object -Unique
$checkBoxCollection = Get-StigCheckBoxCollection -StigList $stigList

$MyDashboard = New-UDDashboard -Title "PowerStig Dashboard" -Content {
    New-UDCard -Title "PowerStig Data Visualization" -Content {
        New-UdParagraph -Text "PowerStig is a PowerShell module that contains several components to automate different DISA Security Technical Implementation Guides (STIGs) where possible.
        If you would like to contibute or view documentation on PowerStig, See the GitHub link below."
    } -Links (New-UdLink -Text 'GitHub' -Url 'https://github.com/Microsoft/PowerStig' -OpenInNewWindow)

    New-UDChart -Title "STIG Data by Rule Type" -Type Doughnut -Endpoint {  
        $groups = $stigData | Group-Object -Property 'RuleType'
        $dataSets = @()
        foreach ($ruleType in $groups)
        { 
            $color = $global:RuleTypeColors.$($ruleType.Name)
            $dataSets += New-UDDoughnutChartDataset -Label $ruleType.Name -DataProperty $ruleType.Count -BackgroundColor $color
        } 
        
        Out-UDChartData -Dataset $dataSets 
    } -Options @{  
        legend = @{  
            display = $true 
        }  
    }

    New-UDCard -Id 'Checkbox frame' -Title 'Supported STIGs' -Content {
        New-UDLayout -Columns 4 -Content {
            foreach ($num in 1..4)
            {
                New-UDCard -Content {
                    foreach ($stigName in $checkBoxCollection.$num)
                    {
                        New-UDCheckbox -Id $stigName -Label $stigName -Checked
                    }
                }
            }
        }
    }
    #New-UDMonitor -Title 'Downloads per second' -Type line -RefreshInterval 5 -DataPointHistory 25 -Endpoint {get-random -Minimum 0 -Maximum 100 | Out-UDMonitorData}
} -Theme (Get-UDTheme -Name 'azure')

function New-StigCheckboxSection
{
    param
    (
        [Parameter(Mandatory = $true)]
        $StigList
    )

    
    foreach ($stig in $StigList)
    {
        New-UDCheckbox -Id $stig 
    }
}
Start-UDDashboard -Port 1000 -Dashboard $MyDashboard -AutoReload


