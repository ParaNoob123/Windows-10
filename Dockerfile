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

# Download Windows 10 ISO (Evaluation ISO from Microsoft 22H2 English x64)
RUN curl -L -o /opt/qemu/win10.iso https://software-download.microsoft.com/pr/Win10_22H2_English_x64.iso

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
ISO="/opt/qemu/win10.iso"

# Create VM disk if it doesn't exist
if [ ! -f "$DISK" ]; then
    echo "Creating Windows 10 VM disk..."
    qemu-img create -f qcow2 "$DISK" 40G
fi

# Start VM booting from ISO
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -smp 1 \
    -m 2048 \
    -drive file="$DISK",format=qcow2,if=virtio \
    -cdrom "$ISO" \
    -boot d \
    -netdev user,id=net0,hostfwd=tcp::2223-:3389 \
    -device e1000,netdev=net0 \
    -vga std \
    -display vnc=:0 \
    -daemonize

# Start noVNC
websockify --web=/novnc 6082 localhost:5900 &

echo "================================================"
echo " 🖥️  VNC: http://localhost:6082/vnc.html"
echo " 💻 Windows 10 setup should start now"
echo " 🔑 After installation, enable RDP inside Windows and connect via localhost:2223"
echo "================================================"

wait
EOF

RUN chmod +x /start.sh

VOLUME /data

EXPOSE 6082 2223

CMD ["/start.sh"]
