#!/bin/bash

#!/bin/bash

# Stop and remove existing container if running
docker stop dymo-cups 2>/dev/null
docker rm dymo-cups 2>/dev/null

# Build the Docker image (force rebuild)
docker build -f docker/Dockerfile -t dymo-cups .

# Run the Docker container using existing br0 network (macvlan in Unraid)
# Assign a fixed IP in the same subnet as your LAN (192.168.1.x)
# Do not create or modify networks, just use the existing br0
docker run -d \
  --name='dymo-cups' \
  --network=br0 \
  --ip=192.168.1.201 \
  -e TZ="Australia/Sydney" \
  -e HOST_OS="Unraid" \
  --device=/dev/bus/usb/001/011 \
  --privileged \
  dymo-cups

echo "DYMO CUPS Docker container started with br0 network and IP 192.168.1.201. Access via LAN."
