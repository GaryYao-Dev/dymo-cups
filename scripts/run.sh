#!/bin/bash
# Stop and remove existing container if running
docker stop dymo-cups 2>/dev/null
docker rm dymo-cups 2>/dev/null
# Configuration
CONTAINER_IP="192.168.1.x"

# Auto-detect DYMO USB device
echo "Detecting DYMO LabelWriter USB device..."
USB_INFO=$(lsusb | grep -i dymo)

if [ -z "$USB_INFO" ]; then
    echo "ERROR: DYMO LabelWriter not found. Please ensure the printer is connected."
    echo "Run 'lsusb' to see all connected USB devices."
    exit 1
fi

echo "Found: $USB_INFO"

# Extract Bus and Device numbers
BUS=$(echo "$USB_INFO" | awk '{print $2}')
DEVICE=$(echo "$USB_INFO" | awk '{print $4}' | sed 's/://')

if [ -z "$BUS" ] || [ -z "$DEVICE" ]; then
    echo "ERROR: Could not parse USB device information."
    exit 1
fi

DEVICE_PATH="/dev/bus/usb/$BUS/$DEVICE"
echo "Using device path: $DEVICE_PATH"

# Stop and remove existing container if running
docker stop dymo-cups 2>/dev/null
docker rm dymo-cups 2>/dev/null

# Build the Docker image if not exists, else rebuild if requested
docker build -f docker/Dockerfile -t dymo-cups .

echo "Using macvlan network br0 with IP $CONTAINER_IP"
docker run -d \
  --name='dymo-cups' \
  --network=br0 \
  --ip=$CONTAINER_IP \
  -e TZ="Australia/Sydney" \
  -e HOST_OS="Unraid" \
  --device=$DEVICE_PATH \
  --privileged \
  dymo-cups

echo "DYMO CUPS Docker container started with br0 network and IP $CONTAINER_IP. Access via LAN."
