# VPN

This document covers VPN access decisions and setup, including the use of WireGuard.

## End Goal

Ideally, the plan is to set up a VPN on the Raspberry Pi
so that I can have remote acess to any local services 
that I may need. This is including but not limited to:
my routers admin page, Pihole management, and Uptime Kuma
mobile interface monitoring.


## Iterations

Tailscale was evaluated for simplicity but deferred due to client-side
installation issues on Windows. WireGuard was selected instead for its
predictability, native client support, and full control over key management.

Here is the next problem I ran into, since the orginal router has the better WiFi card causing 
a secondary router to be in the picture, port forwarding becomes a large issue.
The plan being to double port-forward (although not the best practice it made the 
most sense with my current living situation) The primary router does not
have the option to port-foward to another router. This led me to a design 
iteration in the phsyical topology of my network. I now have my Raspberry 
Pi plugged into the primary router, and I will use it to control anything that 
may need to be done in order for applications to run on the secondary router.

## Approach

This has led me to my current approach, WireGuard with the 
Raspberry Pi plugged directly into the primary router.

## Key Commands

