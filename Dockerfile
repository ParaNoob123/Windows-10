FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    curl \
    unzip \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Create dirs
RUN mkdir -p /data /novnc /opt/qemu

# ✅ Download Windows 10 ISO (English, 22H2, x64) ~5.7GB
RUN curl -L -o /opt/qemu/win10.iso \
    https://archive.org/download/Win10_22H2_English_x64/Win10_22H2_English_x64.iso

# Create empty VM disk (40GB)
RUN qemu-img create -f qcow2 /opt/qemu/win10.img 40G

# Install noVNC
RUN curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.zip -o /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /tmp && mv /tmp/noVNC-1.3.0 /novnc && rm -rf /tmp/*

# Start script
RUN cat <<'EOF' > /start.sh
#!/bin/bash
set -e

DISK="/data/win10.img"
ISO="/opt/qemu/win10.iso"

# If VM disk doesn’t exist, create it
if [ ! -f "$DISK" ]; then
    echo "Creating Windows 10 VM disk..."
    qemu-img create -f qcow2 "$DISK" 40G
fi

# Run VM with CD boot first
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -smp 2 \
    -m 4096 \
    -drive file="$DISK",format=qcow2,if=virtio \
    -cdrom "$ISO" \
    -boot order=d,menu=on \
    -netdev user,id=net0,hostfwd=tcp::2223-:3389 \
    -device e1000,netdev=net0 \
    -vga std \
    -display vnc=:0 &

# Start noVNC
websockify --web=/novnc 6082 localhost:5900
EOF

RUN chmod +x /start.sh

EXPOSE 6082 2223

CMD ["/start.sh"]
