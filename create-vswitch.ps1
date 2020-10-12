New-VMSwitch –SwitchName "NATSwitch" –SwitchType Internal
New-NetIPAddress –IPAddress 172.21.21.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNat –Name MyNATnetwork –InternalIPInterfaceAddressPrefix 172.21.21.0/24