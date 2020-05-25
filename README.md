# Get-CtxHostingPowerActions
Connect to remote XenDesktop farm (CVAD) to obtain data about hosting power actions

## Parameter DdcServers
    List of one Delivery Controller per farm.

## Parameter Credential
    Credentials to connect to remote server and XenDesktop farm (Read-Only)

## Requirements
  Permissions to connect to Deliver Controller through WinRM
  Read-only permissions on Xendesktop farm
  
## Output
    Return data in json format (data can be imported in influxDB)
![Output](https://user-images.githubusercontent.com/23212171/82840789-1ae9b280-9ed4-11ea-908f-cbb37b77e5f4.png)

## Ideas for Grafana
![Grafana_output](https://user-images.githubusercontent.com/23212171/82840791-1cb37600-9ed4-11ea-89a3-32129dff8966.png)
