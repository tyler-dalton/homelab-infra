# Refactoring Proxmox

- I have decided I want to enter a refactoring phase and restart the homelab proccess

Starting with Proxmox, I booted back from the USB, set temporary bridges, and 
established a virtual ethernet (vmbr) connection to my router. 

## Deploy temporary remote access

- I have decided to create a temporary VPN through Tailscale to 
Proxmox so that I have remote access through the refactoring process.

### Next Steps:

Tommorow I will work on spinning up OPNsense (hopefully with terraform) and 
iron out some of the band-aid solutions i put into effect tonight.
