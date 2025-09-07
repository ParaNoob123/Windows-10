FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    curl \
    unzip \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Setup directories
RUN mkdir -p /data /novnc /opt/qemu

# Download pre-installed Windows 10 QCOW2 (Pro 22H2, UEFI, VirtIO)
RUN curl -L -o /opt/qemu/win10.qcow2 \
    https://recolic.net/hms.php?/systems/win10pro-22h2-virtio-uefi.qcow2

# Download Tiny10 alternative (lighter, optional)
RUN curl -L -o /opt/qemu/win10-tiny10.qcow2 \
    https://recolic.net/hms.php?/systems/win10-tiny10-virtio-uefi.qcow2

# Install noVNC for browser access
RUN curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.zip -o /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /tmp && \
    mv /tmp/noVNC-1.3.0 /novnc && \
    rm -rf /tmp/*

# Startup script
RUN cat <<'EOF' > /start.sh
#!/bin/bash
set -e

DISK="/data/win10.img"
BASE="/opt/qemu/win10.qcow2"
TINY="/opt/qemu/win10-tiny10.qcow2"

# Choose which base image to use
IMG="$BASE"
[ -f "$TINY" ] && IMG="$TINY"

# Create a persistent disk overlay
if [ ! -f "$DISK" ]; then
    echo "Creating persistent Windows VM disk..."
    qemu-img create -f qcow2 -b "$IMG" "$DISK" 50G
fi

# Launch VM with VNC and RDP port mapping
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -smp 2 \
    -m 4096 \
    -drive file="$DISK",format=qcow2,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2223-:3389 \
    -device e1000,netdev=net0 \
    -vga std \
    -display vnc=:0 &

# Start noVNC
websockify --web=/novnc 6082 localhost:5900

wait
EOF

RUN chmod +x /start.sh

VOLUME /data

EXPOSE 6082 2223

CMD ["/start.sh"]
