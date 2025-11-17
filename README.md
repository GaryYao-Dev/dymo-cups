# DYMO CUPS Docker for Unraid

This Docker setup allows sharing a DYMO LabelWriter 450 printer over LAN using CUPS.

## Files Structure

- `docker/`: Dockerfile and entrypoint script
- `scripts/`: One-click run script
- `config/`: CUPS configuration files
- `my-dymo-cups.xml`: Unraid Docker template

## Unraid Template Installation

1. On your Unraid server, run `lsusb | grep Dymo` to find the USB device:

   ```
   Bus 001 Device 011: ID 0922:0020 Dymo-CoStar Corp. LabelWriter 450
   ```

   Note the Bus and Device numbers (001/011 in this example).

2. Download `my-dymo-cups.xml` from this repository
3. Copy the file to your Unraid server's `/boot/config/plugins/dockerMan/templates-user/` directory
4. In Unraid web UI, go to Docker > Add Container
5. Select "DYMO CUPS" from the User Templates dropdown
6. Configure the settings:
   - USB Device: `/dev/bus/usb/001/011` (adjust based on your lsusb output)
   - Fixed IP: Set your desired IP address in your LAN subnet
7. Apply and start the container

## Manual Setup (Alternative)

1. Connect your DYMO LabelWriter 450 printer to the Unraid server
2. Upload the `dymo-cups` folder to your Unraid server
3. Edit `scripts/run.sh` and update the IP address:
   - Change `CONTAINER_IP="192.168.1.x"` to your desired IP in your LAN subnet
4. Run `./scripts/run.sh` in the folder (builds from project root and auto-detects USB device)
5. Access CUPS admin at `http://<container-ip>:631`
   - Username: root
   - Password: admin

## Adding Printer on Windows

1. Open Control Panel > Devices and Printers.
2. Add a printer > Network printer.
3. Enter `http://<container-ip>:631/printers/DYMO_LabelWriter_450`.
4. DYMO software should recognize the printer.

## Notes

- USB device is auto-detected by the run script.
- For manual template setup, ensure the USB device path matches `lsusb` output.
- CUPS runs as root for USB access.
- HTTP on port 631 (SSL disabled for stability).
- Requires D-Bus for Avahi service discovery.

## Troubleshooting

- If connection refused: Check `docker ps -a` for container status. If exited, run `docker logs dymo-cups` for errors.
- USB device: Run `lsusb | grep Dymo` on host to verify printer is connected. The script auto-detects the device path.
- HTTPS certificate: Browser may warn about self-signed cert; accept it.
- Printer not found: Check container logs for USB detection and lpinfo output.
- Port conflict: Run `netstat -tlnp | grep 631` on host to check.
