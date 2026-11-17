# syntax=docker/dockerfile:1.7
# Pin a release for reproducible builds. Override, for example:
# docker build --build-arg ARDUPILOT_REF=Copter-4.7.2 -t ardupilot-sitl:4.7.2 .
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG ARDUPILOT_REF=Copter-4.7.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo bash ca-certificates git python3 python3-dev python3-pip python3-venv \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --create-home --uid 10001 -G dialout sitl \
 && sh -c 'echo "sitl    ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers' \
 && mkdir /opt/ardupilot \
 && chown 10001:10001 /opt/ardupilot

WORKDIR /opt/ardupilot
USER sitl
RUN git clone --depth 1 --branch "${ARDUPILOT_REF}" --recurse-submodules \
      https://github.com/ArduPilot/ardupilot.git .
RUN USER=sitl ./Tools/environment_install/install-prereqs-ubuntu.sh -y \
 && sudo rm -rf /var/lib/apt/lists/*
RUN . ~/.profile && ./waf configure --board sitl \
 && ./waf copter plane

# VEHICLE: ArduCopter or ArduPlane
# FRAME examples: quad (Copter), plane (Plane)
# Set LOCATION to a built-in locations.txt name, or set HOME to lat,lon,alt,heading.
# MAVPROXY_OUTS is a space-separated list of MAVProxy --out endpoints.
ENV VEHICLE=ArduCopter \
    FRAME=quad \
    LOCATION=CMAC \
    HOME= \
    INSTANCE=0 \
    SPEEDUP=1 \
    PARAM_FILE= \
    MAVPROXY_OUTS=""

COPY start-sitl /usr/local/bin/
RUN sudo mkdir -p /config /data \
 && sudo chown -R sitl:sitl /config /data

USER sitl
WORKDIR /data
VOLUME ["/config", "/data"]

# SITL's direct TCP endpoint and the default UDP endpoint for host-based tools.
EXPOSE 5760/tcp 14550/udp
ENTRYPOINT ["/usr/local/bin/start-sitl"]
