#!/bin/bash

set -e

echo "Starting DYMO CUPS entrypoint..."

# Generate self-signed SSL certificate for HTTPS (disabled for now)
# echo "Generating SSL certificate..."
# mkdir -p /etc/cups/ssl
# openssl genrsa -out /etc/cups/ssl/server.key 2048
# openssl req -new -x509 -key /etc/cups/ssl/server.key -out /etc/cups/ssl/server.crt -days 365 -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
# chown lp:lp /etc/cups/ssl/server.key /etc/cups/ssl/server.crt
# chmod 600 /etc/cups/ssl/server.key
# chmod 644 /etc/cups/ssl/server.crt

# Set default password for root (for CUPS admin)
echo "Setting root password..."
echo 'root:admin' | chpasswd

# Start D-Bus daemon (clean up stale pid file from previous run)
echo "Starting D-Bus daemon..."
rm -f /run/dbus/pid
mkdir -p /run/dbus
dbus-daemon --system --fork

# Start Avahi daemon for service discovery
echo "Starting Avahi daemon..."
avahi-daemon --daemonize

# Test CUPS configuration
echo "Testing CUPS configuration..."
if ! cupsd -t; then
  echo "CUPS configuration error!"
  exit 1
fi

# Start CUPS daemon in background
echo "Starting CUPS daemon..."
cupsd

# Wait for CUPS to start
sleep 5

echo "Auto-detecting DYMO LabelWriter USB device..."
DYMO_FOUND=false
RETRY_COUNT=0
MAX_RETRIES=12  # Wait up to 1 minute (12 * 5 seconds)

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if lsusb | grep -q "0922:"; then
    DYMO_FOUND=true
    DYMO_INFO=$(lsusb | grep "0922:")
    echo "✓ DYMO device detected: $DYMO_INFO"
    
    # Extract device information
    BUS=$(echo "$DYMO_INFO" | awk '{print $2}')
    DEVICE=$(echo "$DYMO_INFO" | awk '{print $4}' | sed 's/://')
    DEVICE_PATH="/dev/bus/usb/$BUS/$DEVICE"
    echo "  Device path: $DEVICE_PATH"
    
    # Verify device file exists and has proper permissions
    if [ -e "$DEVICE_PATH" ]; then
      echo "  ✓ Device file exists with permissions:"
      ls -l "$DEVICE_PATH"
    else
      echo "  ⚠ WARNING: Device file not found at $DEVICE_PATH"
      echo "  This may indicate missing USB passthrough or incorrect container privileges."
    fi
    break
  fi
  echo "USB device not found, waiting... (attempt $((RETRY_COUNT+1))/$MAX_RETRIES)"
  sleep 5
  RETRY_COUNT=$((RETRY_COUNT+1))
done

if [ "$DYMO_FOUND" = false ]; then
  echo "⚠ WARNING: DYMO device not detected after $MAX_RETRIES attempts."
  echo "Container will continue running, but printer may not be available."
  echo ""
  echo "Troubleshooting:"
  echo "  1. Ensure DYMO printer is connected and powered on"
  echo "  2. Check container is running with --privileged flag"
  echo "  3. Verify USB devices are visible: docker exec <container> lsusb"
fi

# List available USB devices for debugging
echo ""
echo "All USB devices visible to container:"
lsusb
echo ""
echo "Available USB printers detected by CUPS:"
lpinfo -v 2>/dev/null | grep usb || echo "No USB printers found via lpinfo"

# Debugging: List contents of printer-driver-dymo package
echo "Listing contents of printer-driver-dymo package..."
dpkg -L printer-driver-dymo > /tmp/dymo_package_contents.txt 2>&1 || echo "printer-driver-dymo package not found or contents not listed."
cat /tmp/dymo_package_contents.txt

# Run PPD updater (use bash to execute in case it lacks execute permission)
echo "Running printer-driver-dymo.ppd-updater..."
if [ -f /usr/share/cups/ppd-updaters/printer-driver-dymo.ppd-updater ]; then
  chmod +x /usr/share/cups/ppd-updaters/printer-driver-dymo.ppd-updater 2>/dev/null || true
  bash /usr/share/cups/ppd-updaters/printer-driver-dymo.ppd-updater > /tmp/dymo_ppd_updater_output.txt 2>&1 || echo "PPD updater failed."
  cat /tmp/dymo_ppd_updater_output.txt
else
  echo "PPD updater not found, skipping."
fi

# Search for DYMO PPD files again after running updater
echo "Searching for DYMO PPD files again..."
find /usr/share/cups/model /usr/share/ppd -name "*dymo*.ppd*" 2>/dev/null || echo "No DYMO PPD files found."

# Use known USB URI for DYMO LabelWriter 450
USB_URI="usb://DYMO/LabelWriter%20450?serial=01010112345600"
echo "Using USB URI: $USB_URI"

# Add the printer
echo "Adding printer..."
lpadmin -p DYMO_LabelWriter_450 -E -v "$USB_URI" || echo "Failed to add printer"

# Set as default printer
lpadmin -d DYMO_LabelWriter_450

# Enable and start the printer
cupsenable DYMO_LabelWriter_450
cupsaccept DYMO_LabelWriter_450

echo "DYMO LabelWriter 450 printer added and enabled."

# Keep container running
echo "CUPS is running. Container ready."
tail -f /dev/null
