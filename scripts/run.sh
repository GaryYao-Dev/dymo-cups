#!/bin/bash
# Configuration
CONTAINER_IP="192.168.1.x"

echo "========================================="
echo "DYMO CUPS Docker Setup (Auto-Detection)"
echo "========================================="
echo ""

# Check if DYMO printer is connected (optional check)
echo "Checking for DYMO LabelWriter..."
USB_INFO=$(lsusb | grep -i "dymo\|0922:")

if [ -z "$USB_INFO" ]; then
    echo "⚠ WARNING: DYMO LabelWriter not detected on host."
    echo "Container will start anyway and continue checking for device."
    echo ""
    echo "All USB devices:"
    lsusb
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✓ Found: $USB_INFO"
fi

echo ""

# Stop and remove existing container if running
echo "Stopping existing container..."
docker stop dymo-cups 2>/dev/null
docker rm dymo-cups 2>/dev/null

# Build the Docker image
echo "Building Docker image..."
docker build -f docker/Dockerfile -t dymo-cups .

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Docker build failed."
    exit 1
fi

echo ""
echo "Starting container with:"
echo "  - Network: br0"
echo "  - IP: $CONTAINER_IP"
echo "  - USB: Auto-detection enabled (privileged mode)"
echo ""

# Run container with privileged mode for full USB access
docker run -d \
  --name='dymo-cups' \
  --network=br0 \
  --ip=$CONTAINER_IP \
  -e TZ="Australia/Sydney" \
  -e HOST_OS="Unraid" \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  dymo-cups

if [ $? -eq 0 ]; then
    echo "========================================="
    echo "✓ Container started successfully!"
    echo "========================================="
    echo ""
    echo "Access CUPS web interface at:"
    echo "  http://$CONTAINER_IP:631"
    echo ""
    echo "Default credentials:"
    echo "  Username: root"
    echo "  Password: admin"
    echo ""
    echo "To check container logs:"
    echo "  docker logs -f dymo-cups"
    echo ""
    echo "To verify USB device detection:"
    echo "  docker exec dymo-cups lsusb"
    echo "========================================="
else
    echo "❌ ERROR: Failed to start container."
    exit 1
fi
