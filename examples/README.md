# Examples

Docker Compose example systems. Run each one from the hub repo root:

```bash
docker compose -f examples/<example>/docker-compose.yml up
```

| Example | Description |
|---------|-------------|
| [1-quad-basic](1-quad-basic/) | One ArduPilot SITL quadcopter bridged to the OMS bus by rcal-ardupilot and monitored in COSMOS through cosmos-oms. |
| [2-quad-basic](2-quad-basic/) | Two quadcopters, each on its own network and ASB, plus a ground control system (GCS-1) that runs COSMOS and joins the ASBs with `cal_bridge`. |
