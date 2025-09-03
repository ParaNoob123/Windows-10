FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install QEMU, noVNC, and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    curl \
    genisoimage \
    novnc \
    websockify \
    unzip \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /data /novnc /opt/qemu

# Download Windows 10 ISO (Evaluation version from Microsoft)
RUN curl -L -o /opt/qemu/win10.iso https://software-download.microsoft.com/pr/Win10_22H2_English_x64.iso

# Create empty disk (50GB)
RUN qemu-img create -f qcow2 /opt/qemu/win10.img 50G

# Setup noVNC
RUN curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.zip -o /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /tmp && \
    mv /tmp/noVNC-1.3.0/* /novnc && \
    rm -rf /tmp/novnc.zip /tmp/noVNC-1.3.0

# Start script
RUN cat <<'EOF' > /start.sh
#!/bin/bash
set -e

DISK="/data/win10.img"
IMG="/opt/qemu/win10.img"
ISO="/opt/qemu/win10.iso"

# If VM disk does not exist, copy base disk
if [ ! -f "$DISK" ]; then
    echo "Creating persistent VM disk..."
    qemu-img create -f qcow2 "$DISK" 50G
fi

# Start VM (boot from ISO first time)
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -smp 4 \
    -m 8192 \
    -drive file="$DISK",format=qcow2,if=virtio \
    -cdrom "$ISO" \
    -boot d \
    -netdev user,id=net0,hostfwd=tcp::2223-:3389 \
    -device virtio-net,netdev=net0 \
    -vga virtio \
    -display vnc=:0 \
    -daemonize

# Start noVNC
websockify --web=/novnc 6082 localhost:5900 &

echo "================================================"
echo " 🖥️  VNC: http://localhost:6082/vnc.html"
echo " 💻 Install Windows normally through VNC"
echo " 🔑 After installation, use RDP: localhost:2223"
echo "================================================"

wait
EOF

RUN chmod +x /start.sh

VOLUME /data

EXPOSE 6082 2223

CMD ["/start.sh"]
