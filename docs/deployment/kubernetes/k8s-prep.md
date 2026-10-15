# Kubuntu Node Bootstrap Guide

**Purpose:** Prepare a fresh Ubuntu installation for automated configuration through Ansible, GitOps, or another provisioning system.

**Goal:** Minimize manual configuration. Once networking and SSH access are established, all remaining configuration should be automated.

## 1. Install the Operating System

Install Ubuntu using the desired LTS release.

During installation:

- Set a unique hostname.
- Create an administrative user with sudo privileges.
- Install OpenSSH Server if offered.
- Use a consistent username across nodes.

## 2. Configure Static Networking

Identify the network interface:

```bash
ip -br link
ip link show eno1
```

Edit the netplan configuration:

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

The filename may differ between installations. Check `/etc/netplan/` first.

Example for VLAN 33:

```yaml
network:
  version: 2
  ethernets:
    eno1:
      dhcp4: false
      addresses:
        - 192.168.33.15/24
      routes:
        - to: default
          via: 192.168.33.1
      nameservers:
        addresses:
          - 192.168.10.23
```

Replace the IP address and interface name for each node.

Apply and validate:

```bash
sudo netplan generate
sudo netplan try
sudo netplan apply

ip route
ping -c 4 192.168.33.1
ping -c 4 1.1.1.1
getent hosts github.com
```

> [!NOTE]
> Avoid unnecessary `match` and `set-name` directives when the existing interface name is already stable. Check for conflicting Netplan files.

## 3. Enable SSH

Install and enable OpenSSH Server:

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
sudo systemctl status ssh
```

From the management workstation, install your public SSH key:

```bash
ssh-copy-id dalt@192.168.33.15
```

Verify password-less authentication:

```bash
ssh dalt@192.168.33.15
```

SSH key authentication should work before handing the node over to automation.

## 4. Verify Sudo Access

On the target machine:

```bash
sudo whoami
```

Ensure the automation account has the privileges required by the provisioning system.

> [!NOTE]
> If using Ansible with sudo escalation, configure its privilege-escalation method before running playbooks. Password-less sudo is optional, not universally required.

## 5. Verify Remote Connectivity

From the management workstation:

```bash
ping -c 4 192.168.33.15
ssh dalt@192.168.33.15 hostname
```

If connecting remotely through Tailscale, verify that:

- The subnet router advertises `192.168.33.0/24`.
- The route is approved in the Tailscale admin console.
- The management client accepts subnet routes.
- OPNsense permits the necessary traffic between networks.

The Kubernetes nodes do not need individual Tailscale installations if they are reachable through the existing subnet router.

## 6. Hand Off to Automation

Once remote access works, the node is ready for automated provisioning.

The automation system should handle:

- System updates and package installation
- SSH hardening and user management
- Firewall configuration
- Time synchronization
- Kubernetes dependencies and runtime
- Kernel modules and sysctl settings
- Kubernetes installation and cluster joining
- Monitoring, logging, and security tooling

Avoid configuring these manually unless necessary to establish the initial automation connection.

## Bootstrap Completion Checklist

- [x] OS installed and hostname assigned
- [x] Static IP configured
- [x] Default gateway configured
- [x] AdGuard DNS configured
- [x] Gateway, internet, and DNS tested
- [x] OpenSSH installed and enabled
- [x] SSH public key installed
- [x] Sudo access verified
- [x] Remote SSH connectivity verified
- [x] Node accessible to automation controller

**Bootstrap boundary:** Once the checklist passes, stop making manual changes. All subsequent configuration should be reproducible from version-controlled automation.
