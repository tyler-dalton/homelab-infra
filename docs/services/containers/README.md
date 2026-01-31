# Containers

This section documents containerized services deployed via Docker.
All containers are managed through **Portainer**, not directly with docker-compose or CLI tooling.

---

## Container Management

**Platform:** Docker
**Management UI:** Portainer
**Host:** Raspberry Pi
**Restart policy:** unless-stopped

All production services are either:
- Single containers (UI-managed), or
- Portainer Stacks (multi-service deployments)

---

## Stack Usage

Stacks are used when:
- Multiple tightly-coupled services are required
- Shared networks or volumes are involved
- Configuration files must be mounted from the host

Example:
- Monitoring stack (Prometheus + exporters + Grafana)

---

## Persistence

Persistent data is stored using Docker volumes:
- Config directories
- Databases
- Dashboard state

No important data is stored only inside containers.

---

## Monitoring

Every containerized service that exposes a UI or critical function:
- Is added to Uptime Kuma
- Is documented in GitHub
- Is added to Heimdall (if user-facing)
