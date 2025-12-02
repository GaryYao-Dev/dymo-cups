#!/bin/bash
# Script to automatically detect DYMO LabelWriter USB device path
# Run this script on your Unraid server to get the current device path

echo "========================================="
echo "DYMO LabelWriter Device Detection Script"
echo "========================================="
echo ""

# Detect DYMO USB device
USB_INFO=$(lsusb | grep -i "dymo\|0922:")

if [ -z "$USB_INFO" ]; then
    echo "❌ ERROR: DYMO LabelWriter not found."
    echo ""
    echo "Please ensure:"
    echo "  1. The printer is connected via USB"
    echo "  2. The printer is powered on"
    echo ""
    echo "All connected USB devices:"
    lsusb
    exit 1
fi

echo "✓ Found DYMO device:"
echo "  $USB_INFO"
echo ""

# Extract Bus and Device numbers
BUS=$(echo "$USB_INFO" | awk '{print $2}')
DEVICE=$(echo "$USB_INFO" | awk '{print $4}' | sed 's/://')

if [ -z "$BUS" ] || [ -z "$DEVICE" ]; then
    echo "❌ ERROR: Could not parse USB device information."
    exit 1
fi

DEVICE_PATH="/dev/bus/usb/$BUS/$DEVICE"

echo "========================================="
echo "Device Information:"
echo "========================================="
echo "  Bus:         $BUS"
echo "  Device:      $DEVICE"
echo "  Device Path: $DEVICE_PATH"
echo ""

# Check if device file exists
if [ -e "$DEVICE_PATH" ]; then
    echo "✓ Device file exists: $DEVICE_PATH"
    ls -l "$DEVICE_PATH"
else
    echo "⚠ WARNING: Device file not found: $DEVICE_PATH"
fi

echo ""
echo "========================================="
echo "Instructions for Unraid Docker Template:"
echo "========================================="
echo "1. Edit your DYMO CUPS container in Unraid"
echo "2. Find the 'USB Device' configuration"
echo "3. Update the device path to:"
echo ""
echo "   $DEVICE_PATH"
echo ""
echo "4. Click 'Apply' to restart the container"
echo "========================================="
