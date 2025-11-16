#!/bin/bash

# Stop and remove existing container if running
docker stop dymo-cups 2>/dev/null
docker rm dymo-cups 2>/dev/null

# Build the Docker image if not exists, else rebuild if requested
docker images | grep -q dymo-cups || docker build -f docker/Dockerfile -t dymo-cups .

# 仅使用 macvlan (br0) 独立IP模式
CONTAINER_IP="192.168.1.201"
echo "Using macvlan network br0 with IP $CONTAINER_IP"
docker run -d \
  --name='dymo-cups' \
  --network=br0 \
  --ip=$CONTAINER_IP \
  -e TZ="Australia/Sydney" \
  -e HOST_OS="Unraid" \
  --device=/dev/bus/usb/001/011 \
  --privileged \
  dymo-cups
echo "DYMO CUPS Docker container started with br0 network and IP $CONTAINER_IP. Access via LAN."
