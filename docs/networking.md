# Networking

This document covers the networking setup for SentinelPi, my Raspberry PI, including static IP
configuration using NetworkManager.

## Static IP Configuration

The Raspberry Pi was configured with a static IP address using NetworkManager
rather than DHCP reservations on the router. This approach ensures the device
retains a consistent network identity regardless of router behavior or reboots.
I went through this process to bypass the IP configuration issues when having 
two routers in the networking system.

