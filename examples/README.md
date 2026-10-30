# Examples

Docker Compose example systems. Run each one from the hub repo root:

```bash
docker compose -f examples/<example>/docker-compose.yml up
```

| Example | Description |
|---------|-------------|
| [1-quad-basic](1-quad-basic/) | One ArduPilot SITL quadcopter bridged to the OMS bus by rcal-ardupilot and monitored in COSMOS through cosmos-oms. |
| [2-quad-basic](2-quad-basic/) | Two quadcopters, each on its own network and ASB, plus a ground control system (GCS-1) that runs COSMOS and joins the ASBs with `cal_bridge`. |

## Docker Desktop on Windows

Docker Desktop uses a lightweight virtual machine like Hyper-V or WSL-2 when running the desktop. This causes issues with UDP multicast. Trying to send multicast to external networks (physical networks) does not work natively so you won't be able to use, for example, the DDS transport.

There are also issues sending UDP multicast between containers on a docker network. The default docker bridge uses IGMP snooping and if an IGMP querier isn't active, multicast will fail. This can be remedied by giving the docker network a defined name and disabling snooping, which will flood all multicast to all containers on the network.

```yaml
version: '3.8'
services:
  sender:
    image: your-multicast-sender
    networks:
      - mcast-net
  receiver:
    image: your-multicast-receiver
    networks:
      - mcast-net

networks:
  mcast-net:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: mcast-br0
```

After Docker Desktop is running and the network has been created, disable snooping with:

```
wsl.exe -d docker-desktop -u root sh -c "echo 0 > /sys/devices/virtual/net/mcast-br0/bridge/multicast_snooping"
```
