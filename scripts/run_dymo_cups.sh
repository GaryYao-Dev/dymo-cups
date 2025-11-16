#!/bin/bash

# Stop and remove existing container if running
docker stop dymo-cups 2>/dev/null
docker rm dymo-cups 2>/dev/null

# Check if port 631 is in use and try to free it
if netstat -tlnp 2>/dev/null | grep :631 >/dev/null; then
  echo "Port 631 is already in use. Attempting to stop conflicting containers..."
  docker ps -q --filter "publish=631" | xargs -r docker stop
  docker ps -q --filter "publish=631" | xargs -r docker rm
  sleep 5
fi

# Build the Docker image
docker build -f docker/Dockerfile -t dymo-cups .


# Run the Docker container with host network for SMB/IPP broadcast
/usr/local/emhttp/plugins/dynamix.docker.manager/scripts/docker run -d \
  --name='dymo-cups' \
  --net='host' \
  -e TZ="Australia/Sydney" \
  -e HOST_OS="Unraid" \
  --device=/dev/bus/usb/001/011 \
  --privileged \
  dymo-cups

echo "DYMO CUPS Docker container started."