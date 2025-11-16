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

# Start D-Bus daemon
echo "Starting D-Bus daemon..."
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

echo "Waiting for DYMO LabelWriter 450 USB device..."
while ! lsusb | grep -q "0922:0020"; do
  echo "USB device not found, waiting..."
  sleep 5
done

echo "DYMO LabelWriter 450 detected."

# List available USB devices for debugging
echo "Available USB printers:"
lpinfo -v 2>/dev/null | grep usb || echo "No USB printers found via lpinfo"

# Debugging: List contents of printer-driver-dymo package
echo "Listing contents of printer-driver-dymo package..."
dpkg -L printer-driver-dymo > /tmp/dymo_package_contents.txt 2>&1 || echo "printer-driver-dymo package not found or contents not listed."
cat /tmp/dymo_package_contents.txt

# Run PPD updater
echo "Running printer-driver-dymo.ppd-updater..."
/usr/share/cups/ppd-updaters/printer-driver-dymo.ppd-updater > /tmp/dymo_ppd_updater_output.txt 2>&1 || echo "PPD updater failed."
cat /tmp/dymo_ppd_updater_output.txt

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
