#!/bin/sh
# Plays or tears down this example's pods with `podman kube play`.
#
# Prerequisites: ./build.sh (builds cosmos-oms, rcal_radio_bridge, and seeds
# the rcal-configs volume) and ../build_common.sh (ardupilot_sitl,
# rcal_ardupilot) have already been run, and the cosmos-project submodule is
# checked out (git submodule update --init ../../cosmos-project).
#
# Usage:
#   ./run.sh          # play all three pods
#   ./run.sh --down   # tear all three pods down
#
# All three pods join the radio-net Podman network (created below if it
# doesn't exist yet) so each system's radio-bridge-<name> container can
# resolve and dial the others by pod name (e.g. gcs1:7777) over the
# simulated radio link. It isn't torn down by --down, same as rcal-configs.

set -eu
cd "$(dirname "$0")"

if [ "${1:-}" = "--down" ]; then
    podman kube play gcs-1/pod.yaml --down
    podman kube play quad-2/pod.yaml --down
    podman kube play quad-1/pod.yaml --down
    exit 0
fi

podman network exists radio-net || podman network create radio-net

podman kube play --network radio-net quad-1/pod.yaml
podman kube play --network radio-net quad-2/pod.yaml
podman kube play --network radio-net gcs-1/pod.yaml
