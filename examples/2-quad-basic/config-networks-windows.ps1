wsl.exe -d docker-desktop -u root sh -c "echo 0 > /sys/devices/virtual/net/mcast-br0/bridge/multicast_snooping"
wsl.exe -d docker-desktop -u root sh -c "echo 0 > /sys/devices/virtual/net/mcast-br1/bridge/multicast_snooping"
wsl.exe -d docker-desktop -u root sh -c "echo 0 > /sys/devices/virtual/net/mcast-br2/bridge/multicast_snooping"
