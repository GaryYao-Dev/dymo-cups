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

1. Go to Control Panel, change view to Large icons, **right** click `Devices and Printers` , click `Open in new window`![1763353721570](image/README/1763353721570.png)
2. Click Add a printer

   ![1763353935740](image/README/1763353935740.png)

3. Click `The printer that I want isn't listed`

   **DO NOT select the listed printer**

   ![1763354030857](image/README/1763354030857.png)

4. Select Add a printer using an IP address or hostname

   ![1763354133765](image/README/1763354133765.png)

5. `Device Type` select: `TCP/IP Device`

   `Hostname or IP address` paste the url: e.g., `http://192.168.1.201:631/printers/DYMO_LabelWriter_450`

   `Port name` keep the same as `Hostname or IP address`.

   ![1763354246985](https://file+.vscode-resource.vscode-cdn.net/c%3A/Users/Deskmini/Desktop/dymo-cups/image/README/1763354246985.png)

6. Addtional port information required page keep the default setting:

   ![1763354381304](image/README/1763354381304.png)

7. Install the printer driver page, select the right printer

   ![1763354424607](image/README/1763354424607.png)

8. Driver Version page select replace

   ![1763354470291](image/README/1763354470291.png)

9. You should be able to see the printer now is connected in the DYMO Label Software

   ![1763354600381](image/README/1763354600381.png)

## Note

- HTTPS certificate: Browser may warn about self-signed cert; accept it.
