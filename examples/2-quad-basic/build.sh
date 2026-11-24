#!/bin/sh
# Builds this example's images and config volume:
#   - localhost/cosmos-oms:2-quad-basic, from Containerfile.cosmos-oms (an
#     openc3-operator image with the OMS bridge plugin baked in, using
#     this example's A-GRA_subset.xsd and gcs-1/CALConfig.toml). Tagged with
#     the example's directory name, not "latest" - cosmos-oms bakes in one
#     example's CALConfig/XSD at build time, so each example that builds it
#     needs its own tag rather than clobbering a shared one.
#   - localhost/rcal_radio_bridge:2-quad-basic, from Containerfile.radio-bridge
#     (the relay that replaces cal_bridge under Podman; one instance runs in
#     each of quad-1, quad-2, and gcs-1's pods). Tagged per-example for the
#     same reason as cosmos-oms: it's built against this example's
#     A-GRA_subset.xsd.
#   - seeds the rcal-configs named volume with examples/ so
#     RCAL_CALCONFIG_PATH can find each CALConfig.toml under /config
#     once the pods are played (see run.sh).
#
# Prerequisites:
#   - ardupilot_sitl and rcal_ardupilot images: ../build_common.sh
#   - rcal submodule checked out: git submodule update --init ../../rcal
#   - cosmos-oms submodule checked out: git submodule update --init ../../cosmos-oms
#   - rcal-radio-bridge submodule checked out:
#     git submodule update --init ../../rcal-radio-bridge
#   - network access to pull rust:slim-bookworm, ruby:3-slim-bookworm,
#     debian:bookworm-slim, and openc3inc/openc3-operator
#
# Run from this directory: ./build.sh

set -eu
cd "$(dirname "$0")"

# Tag with this example's directory name (see gcs-1/pod.yaml's cosmos-oms
# image reference, which must match).
EXAMPLE=$(basename "$(pwd)")

# Match the openc3-operator base image to the rest of the COSMOS stack in
# gcs-1/pod.yaml (defaults to 7.5.1 if cosmos-project isn't checked out yet).
OPENC3_TAG=$(grep -m1 '^OPENC3_TAG=' ../../cosmos-project/.env 2>/dev/null | cut -d= -f2)
OPENC3_TAG=${OPENC3_TAG:-7.5.1}

podman build \
  -t "cosmos-oms:$EXAMPLE" \
  --build-arg OPENC3_TAG="$OPENC3_TAG" \
  --build-context example=. \
  --build-context rcal=../../rcal/rcal \
  -f Containerfile.cosmos-oms \
  ../../cosmos-oms

podman build \
  -t "rcal_radio_bridge:$EXAMPLE" \
  --build-context radiobridge=../../rcal-radio-bridge \
  --build-context rcal=../../rcal/rcal \
  --build-context example=. \
  -f Containerfile.radio-bridge .

podman volume exists rcal-configs || podman volume create rcal-configs
podman run --rm -v rcal-configs:/config -v "$(cd .. && pwd)":/src:ro,z \
  docker.io/library/debian:bookworm-slim cp -r /src/. /config/
