New-VMSwitch –SwitchName "NATSwitch" –SwitchType Internal
New-NetIPAddress –IPAddress 172.16.1.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNat –Name NATSwitchNetwork –InternalIPInterfaceAddressPrefix 172.16.1.0/24