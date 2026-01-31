# Prometheus (Monitoring Stack)

## Purpose
Prometheus scrapes and stores metrics from exporters (node-exporter, cAdvisor) 
and serves as the backend data source for Grafana.

## Deployment (Portainer Stack: monitoring)
Services:
- prometheus (9090)
- node-exporter (9100)
- cadvisor (8080)
- grafana (3002)

## Config Location (on host)
Prometheus config stored on Raspberry Pi:
- /opt/monitoring/prometheus/prometheus.yml

### Example scrape config
- prometheus: prometheus:9090
- node-exporter: node-exporter:9100
- cadvisor: cadvisor:8080

## Validation
Prometheus UI:
- Status -> Target health
Expected: prometheus, node-exporter, cadvisor are UP.
