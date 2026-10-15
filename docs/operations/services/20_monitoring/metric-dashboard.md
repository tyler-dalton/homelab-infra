# Purpose

I have a spare monitor hooked up to PVE02 node (gridboxx). The purpose behind this setup is so that I can run a short command like 'start-metrics' in the Proxmox cli and it will auto-start a script that will spin up a desktop environment, and load to a Grafana dashboard that I can then display 24/7 near my networking rack. This is a long one, so I hope you have some time, lets buckle in.

# 1. Create the script
In the gridboxx terminal, run:
```bash
nano /usr/local/bin/start-metrics
```
Then inside of that file, create this script:
```bash
#!/bin/bash

export DISPLAY=:0

chromium --kiosk http://grafana.home.lan --noerrdialogs --disable-infobars
```
We will come back and edit this script once we get the full URL to the dashboard, but for now we will leave it as is to be a placeholder.

Now, make it executable:
```bash
chmod +x /usr/local/bin/start-metrics
```
# 2. Create the Grafana instance
Now that we have the script wrote to provision this setup just by running `start-metrics`, we now need to spin up a Grafana instance for it to populate to. We will do this with the help of the Proxmox VE Helper Scripts.

Helper Script: bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/grafana.sh)"

If needed, reference the [grafana](./grafana.md) documentation to help with install.

# 3. Deploy Prometheus instance

Grafana by itself is just a UI dashboard to display metrics, we need something in the backend that will scrape hardware for these metrics. Prometheus will come into play as our backend scraper to retrieve all this data.

Helper Script: bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/prometheus.sh)"

If needed, reference the [prometheus](./prometheus.md) documentation to help with install.

# 4. Connect Prometheus and Grafana
In Grafana, go to Connections, Data sources
- Click `Add a data source`
- Click on Prometheus
- Add in Prometheus URL
- Click `Save & test`

# 5. Add first data source
Choose an LXC that you would like to monitor, we will install node exporter onto it to verify connectivity

Go to the console, and paste this command: `apt install prometheus-node-exporter -y`

Verify with `systemctl status prometheus-node-exporter` You should see active and running.

## 5.2 Add data source to prometheus

Edit the file: `nano /etc/prometheus/prometheus.yml` inside of your Prometheus shell

Under `scrape_config`:
```bash
- job_name: "node"
  static_configs:
	  - targets: ["localhost:9100"]
```

Now, restart Prometheus: `systemctl restart prometheus`

# 6. Verify

Go to the Prometheus web GUI, go to status, then targets
- You should see two instances, one for Prometheus, then one for node, both should be up.

# 7. Add PVE Exporter

## 7.1 Create Proxmox API

Inside of proxmox, go to datacenter, permissions, users, add
- username: REDACTED
- realm: Proxmox VE authentication server

## 7.2 Add permissions for user

Go to datacenter, permissions, add
- User permission
- path: /
- user: REDACTED
- role: PVEAuditor
- propogate: checked

## 7.3 Create API token

Go to datacenter, permissions, API tokens, add
- user: REDACTED@pve
- token ID: REDACTED
Click create, and save the tokenID and secret in a safe place
- token ID: REDACTED
- Secret: REDACTED

# 8. Create the LXC, deploy the exporter

Helper Script: bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/prometheus-pve-exporter.sh)"


If needed, reference the [pve exporter](./pve-exporter.md) documentation to help with install.
# 9. Create Config File

Inside of the LXC, run:
`nano /etc/pve_exporter.yml`

Paste:
```bash
default:
  user: INSERT_USER_CREATED@pve
  token_name: INSERT_TOKEN
  token_value: YOUR_TOKEN_SECRET
  verify_ssl: false
```
  
# 10. Install pip & test manually

Run:
```bash
apt update
apt install -y python3 python3-pip python3-venv build-essential
```

Verify:
```bash
python3 --version
pip3 --version
python3 -m pip --version
```

Run:
`/usr/local/bin/pve_exporter --config.file /etc/pve_exporter.yml`


# 11. Troubleshooting
We got some errors with address already in use, we will need to troubleshoot.

Find out what is running on port 9221, run:
`ss -ltnp | grep 9221`

We are going to start from ground zero, starting with making sure the correct services are running

#### On your Prometheus LXC, run:
```bash
systemctl status prometheus
```

#### On your Grafana LXC, run:
```bash
systemctl status grafana-server
```

#### On PVE Exporter LXC, run:
```bash
systemctl status prometheus-pve-exporter
```

All three of these commands should return that the services are active and running

Now we will test reachability.

#### From Prometheus, try to hit the PVE Exporter:
```bash
curl http://192.168.xx.xx:9221/pve
```
Insert your PVE Exporter IP in for this instance

```bash
curl http://192.168.xx.xx:9221/pve

<!doctype html>
<html lang=en>
<title>500 Internal Server Error</title>
<h1>Internal Server Error</h1>
<p>The server encountered an internal error and was unable to complete your request. Either the server is overloaded or there is an error in the application.</p>
```
This returned us an error, this is a problem.

#### From Grafana, try to hit Prometheus:
```bash
curl http:192.168.xx.xx:9090/-/healthy
```

This should return `Prometheus Server is healthy`

#### Check your scrape targets

Inside of the Prometheus GUI, go to Status, Target health and make sure you have two instances of targets and both are healthy.

We can clearly see our issue is from Prometheus to PVE now. The `500` on /pve is almost always a credential error, I am speculating issues with the API

Run: `cat /etc/pve_exporter.yml`

```bash
default:
  user: INSERT_USER_CREATED@pve
  token_name: INSERT_TOKEN_NAME
  token_value: YOUR_SECRET_WILL_BE_HERE_DO_NOT_SHARE
  verify_ssl: false
```
We can see an issue with our token name. It should just be the token name, not the full token ID string.

Run: `nano /etc/pve_exporter.yml`
Change the token_name to `prometheus-monitor@pve`

Restart and test: 
```bash
systemctl restart prometheus-pve-exporter
curl "http://192.168.xx.xx:9221/pve?target=192.168.xx.xx"
```
Replace the target with your **Proxmox Host IP**

We are still getting errors from the curl command, that means there is still something off.

After some digging, it had to do with the permissions of the Prometheus user in the Proxmox datacenter.

Create a new permission:
- Go to datacenter, permissions, add, API token permission
	- path: /
	- API Token: INSERT_TOKEN_HERE
	- Role: PVEAuditor
	- Propagate: Yes

Now when we run `curl "http://192.168.xx.xx:9221/pve?target=192.168.xx.xx"` We see a whole list of metrics, we have officially gotten over the hump issue we were running into. Now we will add our scrape job to Prometheus.

# 12. Add scrape job to Prometheus

From the Prometheus LXC run `nano /etc/prometheus/prometheus.yml`

Under `scrape_configs` paste this text:
```bash
- job_name: "pve"
    metrics_path: /pve
    params:
      module: [default]
    static_configs:
      - targets: ["192.168.xx.xx"]  # your Proxmox host IP
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: "192.168.xx.xx:9221"  # your PVE exporter LXC
```

Now reload Prometheus by running: `systemctl reload prometheus`

Now if we go back to our Prometheus GUI and reload the targets page we should successfully see our `pve` instance as a third target. This target should be up and actively scraping.

# 13. Create your first dashboard

We will now add our dashboard into Grafana, we will start with an imported dashboard and then edit as needed for the exact use.

Go to your Grafana GUI
- Go to Dashboards, Create a dashboard, Import a dashboard
- Enter the ID `10347` and click load
- Under `DS_PROMETHEUS` select your Prometheus instance from the dropdown
- Click **Import**

There is now a dashboard set up, but it is very information heavy and will not work for this instance. We will now move towards next steps of customizing the imported dashboard.

# 14. Customizing your first dashboard

From here we will just create a new dashboard instance and start from fresh.

- Go to dashboards, create dashboard, add visualization
- Select your Prometheus instance

## 14.1 Set Kiosk / Auto-fit mode

This will be a section specific for the 24/7 always on dashboard.

- On the right side of the screen, click `back to dashboard`
- Click on settings
- Set title to `24-7board`
- Add description if wanted
- Set Auto refresh to 30s

## 14.3 Paneling


### 14.3.1 Node CPU
Click on your new panels three dots:
- Click edit
- In the top right where it says `Time series` change it to `gauge`
- Set the query
	- Scroll down to the query section
	- In the top right, change from **Builder** mode to **Code** mode
	- Insert this command:
	```bash
	pve_cpu_usage_ratio{id="node/hyprboxx"} * 100
	```
Click `Run queries`
- Panel Options:
	- Set title to `hyprbox-cpu`
	- Set transparent background
	- Scroll down to `Standard options`
		- Under `Unit`, type `percent` and select the format of 0-100
- Go back to dashboard
- Rinse and repeat for the other two nodes
- Sizing will be trial and error, find a size that looks right and then we will have to iterate once we see it on the screen

### 14.3.2 Node RAM
Go to add:
- Click visualization
- In the top right where it says `Time series` change it to `gauge`
- Set the query
	- Scroll down to the query section
	- In the top right, change from **Builder** mode to **Code** mode
	- Insert this command:
	```bash
	pve_memory_usage_bytes{id="node/hyprboxx"} / pve_memory_size_bytes{id="node/hyprboxx"} * 100
	```
Click `Run queries`
- Panel Options:
	- Set title to `hyprbox-ram`
	- Set transparent background
	- Scroll down to `Standard options`
		- Under `Unit`, type `percent` and select the format of 0-100
- Go back to dashboard
- Rinse and repeat for the other two nodes

### 14.3.3 VM/LXC Status by VLAN
Go to add:
- Click visualization
- In the top right where it says `Time series` change it to `stat`
- Set the query
	- Scroll down to the query section
	- In the top right, change from **Builder** mode to **Code** mode
	- Insert this command:
	```bash
	pve_up * on(id) group_left(name) pve_guest_info{tags=~".*mgmt.*"}
	```
	- Under the query, expand the options
		- Change **Type** from `Range` to `Instant`
		- Change **Format** from `Time Series` to `Table`
Click `Run queries`
- Panel Options:
	- Set title to `mgmt-stat`
	- Under **Stat Styles** set **Text mode** to **Name** and **Color mode** to **Background gradient**
	- Set `Value options` to **All values**
	- Change `Orientation` from **Auto** to **Horizonal**
	- Change `Text mode` from **Auto** to **Name**
	- Set Thresholds:
		- 0 = red
		- 1 = green
Go to the transformations tab
- Add transformation, click on **Organize fields by name**
	- Toggle these fields off by clicking the eye by their name
		- Time
		- Instance
		- Job
- Go back to dashboard
- Rinse and repeat for each VLAN, the way that this is set up, any time we add a service, as long as we include the correct tag it should get added onto the dashboard.

### 14.3.4 Uptime Stats (Per node)
Go to add:
- Click visualization
- In the top right where it says `Time series` change it to `stat`
- Set the query
	- Scroll down to the query section
	- In the top right, change from **Builder** mode to **Code** mode
	- Insert this command:
	```bash
	pve_uptime_seconds{id="node/hyprboxx"}
	```
Click `Run queries`
- Panel Options:
	- Set title to `hyprbox-up`
	- Set transparent background
	- Scroll down to `Standard options`
		- Under `Unit`, type `dur` and select `duration (d hh:mm:ss)`
	- Change color scheme to `Classic Palette`
- Go back to dashboard
- Rinse and repeat for the other two nodes

# 15. Tailoring the script

Before we make some edits to the script there are some packages we need to install. Run this command to install all the packages at once: 
```bash
apt update && apt install -y xorg chromium unclutter
```

Now we will get into some deep config changes for our script. Open up the script at the path `/usr/local/bin/start-metrics`
Paste this inside:
```bash
#!/bin/bash 
export DISPLAY=:0 
Xorg :0 & 
sleep 2 
unclutter -idle 0 -root & 
chromium --kiosk
--noerrdialogs
--disable-infobars
--disable-session-crashed-bubble
--disable-restore-session-state
--no-sandbox
"http://192.168.xx.xx:3000/d/adrbrnx/24-7board?orgId=1&refresh=30s&kiosk" 
& 
echo "Metrics dashboard started. Ctrl+Alt+F2 for CLI, Ctrl+Alt+F7 to return."
```

Now we will also create a **stop-metrics** script

Edit and create the file at the path of `/usr/local/bin/stop-metrics` and paste in these contents:
```bash
#!/bin/bash 
pkill chromium 
pkill unclutter 
pkill Xorg 
echo "Metrics dashboard stopped."
```

Make both scripts executable:
```bash
chmod +x /usr/local/bin/start-metrics 
chmod +x /usr/local/bin/stop-metrics
```

Test running the script it just gave a black screen. Run `Ctrl+Alt+F1` to get back to the CLI terminal.

Run these two process troubleshooting commands:
```bash
pgrep Xorg
pgrep chromium
```
We see a PID for Xorg but not for chromium, so Xorg started but not chromium. 

Error seems to be because we did not add the `no-sandbox` attribute to the end of the script. Go into your start metrics script and add `--no-sandbox` at the end of the attributes

Now testing we can see we get prompted to log into Grafana. Which leads us to our next section.

# 16. Enable anonymous access in Grafana

Edit the file `/etc/grafana/grafana.ini`

Find the `[auth.anonymous]` section and set:
```bash
##################### Anonymous Auth ######################
[auth.anonymous]
# enable anonymous access
enabled = true 

# specify organization name that should be used for unauthenticated users
org_name = Main Org.

# specify role for unauthenticated users
org_role = Viewer

# mask the Grafana version number for unauthenticated users
;hide_version = false

# number of devices in total
;device_limit =
```
Restart Grafana: `systemctl restart grafana-server`

# 17. Testing

On the monitor run `start-metrics`

This test gives us some valuable input:
- We can confirm that the instance is working
- We have some extra space vertically
- The dashboard is only displaying to the left of the screen 

Add these two attributes to your script file:
```bash
--window-position=0,0
--window-size=1680,1050
```

Now it is fitting the full size off the screen, and we just need to do some minor edits to change the sizing to fill up our empty space. 
