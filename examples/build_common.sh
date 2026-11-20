#!/bin/sh

podman build -t ardupilot_sitl:latest -f ../ardupilot/Containerfile ../ardupilot
podman build -t rcal_ardupilot:latest -f ../rcal-ardupilot/Containerfile ../rcal-ardupilot
podman build -t cosmos_oms:latest -f ../cosmos_oms/Containerfile ../cosmos_oms
