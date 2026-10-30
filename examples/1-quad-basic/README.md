# 1-quad-basic

One simulated quadcopter on the OMS bus.

```
ArduPilot SITL → rcal-ardupilot → OMS bus → cosmos-oms → OpenC3/COSMOS
```

| Service | Role |
|---------|------|
| `ardupilot-sitl` | ArduPilot SITL running ArduCopter. Sends MAVLink over UDP 14550. |
| `rcal-ardupilot` | Translates MAVLink into UCI messages and publishes them on the OMS bus. |
| `cosmos-oms` | Subscribes to the OMS bus and feeds the UCI messages to COSMOS as telemetry. |

## Files

| File | Contents |
|------|----------|
| `CALConfig.toml` | The QUAD-1 system: `rcal_sim` gateway service and `oms_ingest` cosmos-oms service on DDS domain 0. |
| `A-GRA_subset.xsd` | The A-GRA ASK 6.0a messages this system uses, plus their supporting types. Generated with rcal's `xsd-subset` tool. See [2-quad-basic](../2-quad-basic/README.md#files) for the command. |

## Run

From the hub repo root:

```bash
docker compose -f examples/1-quad-basic/docker-compose.yml up
```

Requires Docker 24+ with Compose V2. The image tags are placeholders. See each component repo for build instructions.
