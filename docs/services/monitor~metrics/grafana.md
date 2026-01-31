# Grafana

## Purpose
Grafana provides dashboards/visualization over Prometheus metrics.

## Deployment (Portainer Stack: monitoring)
- Image: grafana/grafana:latest
- Port mapping: 3002 -> 3000
- Volume: grafana-data -> /var/lib/grafana
- Restart: unless-stopped

## Dashboards Imported
- Node Exporter Full (ID: 1860) — host metrics (CPU/RAM/disk/network)
- Docker / Container dashboard (ID: 193) — per-container CPU/mem/network
