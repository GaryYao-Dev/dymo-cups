FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Sydney

# Update package lists
RUN apt-get update

# Install CUPS base packages
RUN apt-get install -y cups cups-client cups-bsd cups-filters

# Install printer drivers
RUN apt-get install -y printer-driver-all printer-driver-dymo

# Install USB utilities
RUN apt-get install -y usbutils

# Install Avahi for service discovery
RUN apt-get install -y avahi-daemon avahi-utils


# Install additional tools
RUN apt-get install -y openssl dbus
RUN apt-get install -y net-tools

RUN rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/spool/cups /var/cache/cups /var/run/cups /var/run/dbus
RUN chown -R lp:lp /var/spool/cups /var/cache/cups /var/run/cups

# Create CUPS user and group
RUN useradd -r -g lp -s /bin/false cups

# Configure CUPS
COPY config/cupsd.conf /etc/cups/cupsd.conf
COPY config/cups-files.conf /etc/cups/cups-files.conf

# Set permissions
RUN chown root:root /etc/cups/cupsd.conf /etc/cups/cups-files.conf
RUN chmod 644 /etc/cups/cupsd.conf /etc/cups/cups-files.conf

# Expose CUPS port
EXPOSE 631

# Copy entrypoint script
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:631/ || exit 1

# Start entrypoint
CMD ["/entrypoint.sh"]
