# 2-quad-basic

Two simulated quadcopters and a ground control system (GCS-1). Builds on [1-quad-basic](../1-quad-basic/) by adding a second vehicle and giving each system its own network and ASB.

```
[quad-1] ArduPilot SITL → rcal-ardupilot-1 → ASB (DDS domain 1) ─┐
                                                                ├→ cal_bridge → ASB (DDS domain 0) → cosmos-oms   [gcs-1]
[quad-2] ArduPilot SITL → rcal-ardupilot-2 → ASB (DDS domain 2) ─┘
```

| Network | ASB | Services |
|---------|-----|----------|
| `quad-1` | DDS domain 1 | `ardupilot-sitl-1` (ArduCopter SITL, instance 0, MAVLink system ID 1), `rcal-ardupilot-1` |
| `quad-2` | DDS domain 2 | `ardupilot-sitl-2` (ArduCopter SITL, instance 1, MAVLink system ID 2), `rcal-ardupilot-2` |
| `gcs-1` | DDS domain 0 | `cal-bridge`, `cosmos-oms` |

The two quad networks are not connected to each other. `cal-bridge` runs rcal's `cal_bridge` and is the only container on all three networks. It repeats every message on the `CalBridge` topics in [gcs-1/CALConfig.toml](gcs-1/CALConfig.toml) from each ASB to the other two. The two quads therefore also see each other's messages, but only through the bridge.

Each ASB uses its own DDS domain. This keeps the bridge from hearing its own forwarded messages on another transport.

## Files

| File | Contents |
|------|----------|
| `quad-1/CALConfig.toml` | QUAD-1 system: `rcal_sim` gateway service on DDS domain 1. |
| `quad-2/CALConfig.toml` | QUAD-2 system: `rcal_sim` gateway service on DDS domain 2. |
| `gcs-1/CALConfig.toml` | GCS-1 system: `CalBridge` service and `[bridge]` section for cal_bridge, and the `oms_ingest` service for cosmos-oms on DDS domain 0. |
| `A-GRA_subset.xsd` | The A-GRA ASK 6.0a messages these systems use, plus their supporting types. |

Each quad is a separate OMS system with its own system ID and UUID, so subscribers can tell the two vehicles apart.

`A-GRA_subset.xsd` was generated with rcal's `xsd-subset` tool from `specs/a-gra/Schema`:

```bash
xsd-subset --schema A-GRA_MessageDefinitions_v6_0_a.xsd -o A-GRA_subset.xsd \
  PositionReport SystemStatus NavigationReport FlightCapabilityStatus \
  FlightActivity SubsystemStatus ServiceStatus
```

The main schema includes `A-GRA_SecurityMarkings_v6_0.xsd`, but the file in the kit is named `A-GRA_SecurityMarkings_v6_0_a.xsd`. Copy both files to a working directory and rename the security markings file before running the tool.

## Run

From the hub repo root:

```bash
docker compose -f examples/2-quad-basic/docker-compose.yml up
```

Requires Docker 24+ with Compose V2. The image tags are placeholders. See each component repo for build instructions.
