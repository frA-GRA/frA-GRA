#!/bin/sh
# Builds the images shared by every example in this directory:
#   - ardupilot_sitl: ArduPilot SITL (ArduCopter)
#   - rcal_ardupilot: MAVLink-to-UCI gateway, built self-contained with the
#     A-GRA subset schema bundled in rcal-ardupilot/docker/
#
# cosmos-oms is NOT built here. It bakes one example's A-GRA_subset.xsd and
# CALConfig.toml into its generated COSMOS telemetry definitions at build
# time (see cosmos-oms/build.rs), so there's no single "common" image for
# it. Each example that uses it builds its own; see
# examples/2-quad-basic/build.sh.
#
# Safe to run from anywhere: cds to this script's directory first.

set -eu
cd "$(dirname "$0")"

podman build -t ardupilot_sitl:latest -f ../ardupilot/Containerfile ../ardupilot
podman build -t rcal_ardupilot:latest \
  --build-context rcal=../rcal/rcal \
  -f ../rcal-ardupilot/Containerfile ../rcal-ardupilot
