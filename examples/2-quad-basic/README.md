# 2-quad-basic

Two simulated quadcopters and a ground control system (GCS-1). Builds on [1-quad-basic](../1-quad-basic/) by adding a second vehicle and giving each system its own network and ASB.

```
[quad-1] ArduPilot SITL → rcal-ardupilot-1 → ASB (DDS domain 1) → radio-bridge-quad1 ─┐
                                                                                      │ radio-net (UDP)
[quad-2] ArduPilot SITL → rcal-ardupilot-2 → ASB (DDS domain 2) → radio-bridge-quad2 ─┼─→ radio-bridge-gcs1 → ASB (DDS domain 0) → cosmos-oms   [gcs-1]
                                                                                      ┘
```

| Network | ASB | Services |
|---------|-----|----------|
| `quad-1` | DDS domain 1 | `ardupilot-sitl-1` (ArduCopter SITL, instance 0, MAVLink system ID 1), `rcal-ardupilot-1`, `radio-bridge-quad1` |
| `quad-2` | DDS domain 2 | `ardupilot-sitl-2` (ArduCopter SITL, instance 1, MAVLink system ID 2), `rcal-ardupilot-2`, `radio-bridge-quad2` |
| `gcs-1` | DDS domain 0 | `radio-bridge-gcs1`, `cosmos-oms` |

The two quad networks are not connected to each other over DDS. Each system runs its own `rcal_radio_bridge` instance, which joins that system's local ASB plus the shared `radio-net` network and relays the `RadioBridge` topics in each `CALConfig.toml` over a reliable UDP link (ENet) instead of joining another DDS domain directly. The quads each dial `radio-bridge-gcs1`; `gcs-1` only listens and relays N-way, so it's the hub. The two quads therefore also see each other's messages, but only through `radio-bridge-gcs1` — the same star topology `cal_bridge` used to produce.

Each ASB uses its own DDS domain. This keeps each radio bridge from hearing its own forwarded messages on another transport.

## Files

| File | Contents |
|------|----------|
| `quad-1/CALConfig.toml` | QUAD-1 system: `rcal_sim` gateway service and `RadioBridge` service (dials gcs-1) on DDS domain 1. |
| `quad-2/CALConfig.toml` | QUAD-2 system: `rcal_sim` gateway service and `RadioBridge` service (dials gcs-1) on DDS domain 2. |
| `gcs-1/CALConfig.toml` | GCS-1 system: `RadioBridge` service (listen-only, hub) and the `oms_ingest` service for cosmos-oms on DDS domain 0. |
| `Containerfile.radio-bridge` | Builds `localhost/rcal_radio_bridge:2-quad-basic` from the `rcal-radio-bridge` submodule, patched against the local `rcal` submodule and this example's `A-GRA_subset.xsd` (same crates.io/A-GRA workaround as `Containerfile.cosmos-oms`). |
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

## Run with Podman

`quad-1/pod.yaml`, `quad-2/pod.yaml`, and `gcs-1/pod.yaml` are Kubernetes Pod
specs for `podman kube play`. Each quad pod runs `sitl-quad<N>`
(`localhost/ardupilot_sitl:latest`), `rcal-ardupilot-quad<N>`
(`localhost/rcal_ardupilot:latest`), and `radio-bridge-quad<N>`
(`localhost/rcal_radio_bridge:2-quad-basic`). `gcs-1/pod.yaml` runs `cosmos-oms`
(`localhost/cosmos-oms:2-quad-basic`, standing in for `openc3-operator`) and
`radio-bridge-gcs1` (same `rcal_radio_bridge` image) alongside
every other container needed for a full COSMOS instance from the
[`cosmos-project`](../../cosmos-project) submodule: `openc3-buckets`,
`openc3-tsdb`, `openc3-redis`, `openc3-redis-ephemeral`,
`openc3-cosmos-cmd-tlm-api`, `openc3-cosmos-script-runner-api`,
`openc3-traefik`, and `openc3-cosmos-init`.

Under Podman each system is an isolated pod rather than being multi-homed
onto all three networks the way `cal_bridge` was under Docker Compose, so
there's no container that can join all three DDS domains directly anymore.
`radio-bridge-<name>` restores the same connectivity instead: one instance
per pod relays its system's local ASB to/from the others over a reliable UDP
link on the shared `radio-net` Podman network (see the comment at the top of
`gcs-1/pod.yaml`), with `gcs-1` as the hub — same star topology, same "quads
see each other only through the hub" behavior, just over UDP hops instead of
a multi-homed container.

Prerequisites:

- `ardupilot_sitl` and `rcal_ardupilot` images built locally: from `examples/`,
  run [`./build_common.sh`](../build_common.sh).
- The `cosmos-project` submodule checked out:
  `git submodule update --init ../../cosmos-project` (from this directory).
- The `rcal-radio-bridge` submodule checked out:
  `git submodule update --init ../../rcal-radio-bridge` (from this directory).
- From this directory, run [`./build.sh`](build.sh). It builds
  `localhost/cosmos-oms:2-quad-basic` from [`Containerfile.cosmos-oms`](Containerfile.cosmos-oms)
  (tagged with the example's directory name since cosmos-oms bakes in one
  example's CALConfig/XSD at build time), which bakes `gcs-1/CALConfig.toml`
  and `A-GRA_subset.xsd` into the
  generated COSMOS telemetry definitions (mirrors the `cosmos-oms` build in
  `docker-compose.yml`), and `localhost/rcal_radio_bridge:2-quad-basic` from
  [`Containerfile.radio-bridge`](Containerfile.radio-bridge) (same per-example
  tagging and local-`rcal`-submodule/`A-GRA_subset.xsd` workaround as
  `cosmos-oms`, since the published `rcal` crate doesn't yet compile against
  A-GRA), then seeds a `rcal-configs` named volume with
  `examples/` so `RCAL_CALCONFIG_PATH` can find each `CALConfig.toml` under
  `/config/2-quad-basic/...`.

Then [`./run.sh`](run.sh) creates the `radio-net` network (if it doesn't
already exist) and plays `quad-1/pod.yaml`, `quad-2/pod.yaml`, and
`gcs-1/pod.yaml` on it with `podman kube play`:

```bash
./build.sh
./run.sh          # play all three pods
./run.sh --down   # tear everything down
```

Equivalent by hand, from `examples/2-quad-basic/`:

```bash
podman build -t cosmos-oms:2-quad-basic --build-arg OPENC3_TAG=7.5.1 \
  --build-context example=. --build-context rcal=../../rcal/rcal \
  -f Containerfile.cosmos-oms ../../cosmos-oms

podman build -t rcal_radio_bridge:2-quad-basic \
  --build-context radiobridge=../../rcal-radio-bridge \
  --build-context rcal=../../rcal/rcal --build-context example=. \
  -f Containerfile.radio-bridge .

podman volume create rcal-configs
podman run --rm -v rcal-configs:/config -v "$(pwd)/..":/src:ro,z \
  docker.io/library/debian:bookworm-slim cp -r /src/. /config/

podman network create radio-net

podman kube play --network radio-net quad-1/pod.yaml
podman kube play --network radio-net quad-2/pod.yaml
podman kube play --network radio-net gcs-1/pod.yaml   # run from here: gcs-1's hostPath volumes are relative to examples/2-quad-basic
```

Tear down with `podman kube play <file> --down` for each.
