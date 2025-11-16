# DYMO CUPS Docker for Unraid

This Docker setup allows sharing a DYMO LabelWriter 450 printer over LAN using CUPS.

## Files Structure

- `docker/`: Dockerfile and entrypoint script
- `scripts/`: One-click run script
- `config/`: CUPS configuration files

## Setup

1. Upload the `dymo-cups` folder to your Unraid server.
2. Run `./scripts/run_dymo_cups.sh` in the folder (builds from project root).
3. Access CUPS admin at `http://<unraid-ip>:631` (or `https://` if SSL enabled).
   - Username: root
   - Password: admin

## Adding Printer on Windows

1. Open Control Panel > Devices and Printers.
2. Add a printer > Network printer.
3. Enter `http://<unraid-ip>:631/printers/DYMO_LabelWriter_450` or `\\<unraid-ip>:1445\DYMO_LabelWriter_450` (SMB on port 1445).
4. DYMO software should recognize the printer.

## Notes

- USB device is mapped as `/dev/bus/usb/001/011`.
- If device path differs, update the script.
- CUPS runs as root for USB access.
- HTTP on port 631 (SSL disabled for stability).
- Requires D-Bus for Avahi service discovery.
- SMB sharing enabled for Windows network discovery.

## Troubleshooting

- If connection refused: Check `docker ps -a` for container status. If exited, run `docker logs dymo-cups` for errors.
- USB device: Ensure `--device=/dev/bus/usb/001/011` matches `lsusb` output on host.
- HTTPS certificate: Browser may warn about self-signed cert; accept it.
- Printer not found: Check container logs for USB detection and lpinfo output.
- Port conflict: Run `netstat -tlnp | grep 631` on host to check.
