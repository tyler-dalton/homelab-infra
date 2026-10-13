- take snapshot of OPNsense config
  - `System` -> `Configuration` -> `Backups` -> `Download configuration`
 
INSERT opn-bak IMAGE

- snapshot OPNsense VM
  - `OPNsense VM` -> `Backups` -> `Backup now` -> `Backup`
 
INSERT pve-opn-back IMAGE

- Create Kubernetes VLAN 33
  - `Interfaces` -> `Devices` -> `VLAN` -> `+`

INSERT create-vlan33 IMAGE

- `Interfaces` -> `Assignments`

INSERT vlan33-assign IMAGE

33-enable-int

- `Firewall` -> `Rules` -> `Rules`

## Netgear Switch Config

- create vlan 33
 - `Switching` -> `VLAN` -> `Advanced` -> `VLAN Configuration`

net-add-33

 - `Switching` -> `VLAN` -> `Advanced` -> `VLAN Membership`

net-33-ports

 - `Switching` -> `VLAN` -> `Advanced` -> `Port PVID Configuration`

port-pvid
