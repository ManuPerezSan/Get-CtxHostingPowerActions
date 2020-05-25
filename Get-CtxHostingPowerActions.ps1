<#
.SYNOPSIS
    Connect to remote XenDesktop farm (CVAD) to obtain data about hosting power actions.

.PARAMETER DdcServers
    List of one Delivery Controller per farm.

.PARAMETER Credential
    Credentials to connect to remote server and XenDesktop farm (Read-Only)

.RETURN
    Return data in json format (data can be imported in influxDB)
    
.AUTHOR
    Manuel Pérez

.PROJECTURI
    https://github.com/ManuPerezSan

.REQUIREMENTS

#>
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true, Position=0)][string[]]$DdcServers,
[Parameter(Mandatory=$true, Position=1)][pscredential]$Credential
)

$powerActionsData = @()

Foreach($ddc in $DdcServers){

    $s01 = New-PsSession -Computer $ddc -Credential $Credential

    try{
        
        $returnedData = Invoke-command -Session $s01 -ScriptBlock{

            $array=@()

            Add-PSSnapin citrix.*
            $HostingUnits = Get-BrokerHypervisorConnection -AdminAddress localhost

            foreach($hu in $HostingUnits){
              $powerActions = Get-BrokerHostingPowerAction -MaxRecordCount 10000 -HypervisorConnectionName "$($hu.Name)"| where{$_.ActionStartTime -ge (Get-Date -UFormat '%Y/%m/%d')}
              
              $Object = New-Object PSObject
              $State = New-Object PSObject
              $Actions = New-Object PSObject

              $totalPowerState = $powerActions| group State
              $totalPowerActions = $powerActions| group Action

              # State actions
              $State | add-member Noteproperty 'Completed' ($totalPowerState | ? Name -eq 'Completed').Count
              $State | add-member Noteproperty 'Failed' ($totalPowerState | ? Name -eq 'Failed').count
              $State | add-member Noteproperty 'Lost' ($totalPowerState | ? Name -eq 'Lost').count
              $State | add-member Noteproperty 'Pending' ($totalPowerState | ? Name -eq 'Pending').count
              $State | add-member Noteproperty TotalState $powerActions.count  
            
              # Action actions
              $Actions | add-member Noteproperty 'TurnOn' ($totalPowerActions | ? Name -eq 'TurnOn').Count
              $Actions | add-member Noteproperty 'Restart' ($totalPowerActions | ? Name -eq 'Restart').Count
              $Actions | add-member Noteproperty 'Shutdown' ($totalPowerActions | ? Name -eq 'Shutdown').Count
              $Actions | add-member Noteproperty 'TurnOff' ($totalPowerActions | ? Name -eq 'TurnOff').Count
              $Actions | add-member Noteproperty 'Reset' ($totalPowerActions | ? Name -eq 'Reset').Count
              $Actions | add-member Noteproperty TotalActions $powerActions.count

              $Object | add-member Noteproperty HostingUnitName "$($hu.Name)"
              $Object | add-member Noteproperty State $State
              $Object | add-member Noteproperty Actions $Actions

              $array += $Object
            
            }

            return $array

        } | Select -Property HostingUnitName, State, Actions

    }catch{
        Remove-PSSession $s01 -Confirm:$false
    }

    Remove-PSSession $s01 -Confirm:$false

    $powerActionsData += $returnedData

}

ConvertTo-Json $powerActionsData -Depth 2 #-Compress
