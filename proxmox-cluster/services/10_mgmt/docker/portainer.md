# Portainer Installation Guide

## Step-by-step deployment notes for Portainer CE on the Docker VM.





## Prerequisites

• Docker Engine and Docker Compose should already be functioning inside the Docker VM.

• The documented Docker VM address is 192.168.10.24, which is also used for Portainer access in the notes.

• Port 9443 is the preferred HTTPS management entry point; port 9000 is also published by the container run command.

### Deploy the Portainer container

1. From the Docker VM shell, run the documented container command to launch Portainer CE with persistent data and automatic restart.

2. Publish ports 9000 and 9443, mount /var/run/docker.sock so Portainer can manage the local Docker engine, and mount the named volume portainer_data to /data.

3. Confirm the container starts cleanly with docker ps and inspect logs with docker logs portainer if needed.

Complete first-run setup

1. Open https://192.168.10.x:9443 in a browser and accept the certificate warning if you are using the default self-signed certificate.

2. Create the initial Portainer administrator account when the onboarding page appears.

3. Select the local Docker environment so the UI attaches to the Docker socket mounted from the host VM.

Post-install checks

1. Verify the Portainer dashboard loads and that the local environment reports healthy status.

2. Open the Containers view and confirm you can see the running Portainer container itself.

3. Record the URL, admin username, container name, and the existence of the portainer_data volume in your HomeLab notes.