verify:
- hostname
- `192.168.33.xx` (3, 4, 5, 6, 7)
- default route is `192.168.33.1`

confirmation commands:

```bash
ip route
resolvectl status
ping -c 4 1.1.1.1
getent hosts github.com
```

sample netplan config file found by `sudo nano /etc/netplan/00

```00.yaml
network:
  ethernets:
    eno1:
      dhcp4: false
      addresses:
        - 192.168.33.11/24
      routes:
        - to: default
          via: 192.168.33.1
      nameservers:
        addresses:
          - 192.168.10.23
      match:
        macaddress: SYSTEM_MAC
      set-name: eno1
  version: 2
```alright ive got ubuntu node one plugged up. what needs to 

install & enable SSH

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
sudo systemctl status ssh
```

From management console:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub dalt@192.168.33.11
ssh dalt@192.168.33.11
```
