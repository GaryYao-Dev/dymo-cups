# Changelog

## [Unreleased] - Auto-Detection Update

### ✨ Added

- **Automatic USB device detection** - No more manual device path configuration!
- Container now mounts entire `/dev/bus/usb` tree for dynamic device discovery
- Enhanced logging and troubleshooting information in entrypoint script
- Improved error messages and device detection feedback

### 🔧 Changed

- Updated `run.sh` script to use volume mount instead of individual device passthrough
- Simplified Unraid template - removed manual USB device path configuration
- Updated README with simplified installation instructions
- Modified `entrypoint.sh` with better device detection logic and retry mechanism

### 🐛 Fixed

- **USB device number changes after reboot** - Now automatically handled!
- Container continues running even if printer is temporarily disconnected
- Better error handling and graceful degradation

### 📝 Documentation

- Added comprehensive troubleshooting section to README
- Created helper script `get-dymo-device.sh` for manual diagnostics
- Updated all documentation to reflect auto-detection feature

## Benefits

- **Zero configuration after setup** - Works across reboots automatically
- **No manual device path updates** - Container discovers printer dynamically
- **Better user experience** - Clear logging and helpful error messages
- **More robust** - Handles printer disconnection gracefully

## Migration from Previous Version

If you're using the old version:

1. Update your container configuration
2. Change USB Device setting from `/dev/bus/usb/001/011` to `/dev/bus/usb`
3. Ensure container runs in privileged mode
4. Restart container - that's it!

The printer will be automatically detected regardless of which USB port or device number it uses.
