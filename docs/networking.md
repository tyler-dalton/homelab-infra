# Networking

This document covers the networking setup for SentinelPi, my Raspberry PI, including static IP
configuration using NetworkManager.

## Overview

Being in a college house, living with multiple roomates, can cause
for a homelab setup to have some workarounds. On the bright side, it definetly 
improves critical thinking and shows true application of skills

## Overall Network Topology

My home network infrastructure is definetly not ideal, but it makes the house happy 
and I still get to work on the skills I need to. I have a Spectrum router with a WiFi 7 card
attatched to the modem, from there I have my Pi and Netgear router (WiFi 5 Card) 
etherneted into the Spectrum router. I want the control of the Netgear, but the speeds of 
the Spectrum, so I settled for this configuration.

## Static IP Configuration

The Raspberry Pi was configured with a static IP address in the Spectrum UI. 
Although I would have liked to statically assign the IP using NetworkManager, in order 
to access port-forwarding, I need to assign the static IP in the UI. This ensures that 
over time and through reboots the IP of my Raspberry Pi will never change. Having this static 
IP allows for some cool network applications, and also gives me access to remote connect 
from anywhere around the world as long as I have the VPN working and my static IP.

