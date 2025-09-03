🪟 Windows 10 QEMU Virtual Machine in Docker Container

A lightweight Windows 10 virtual machine running inside a Docker container using QEMU/KVM for optimal performance.

Features

🐳 Containerized Windows 10 VM

⚡ KVM-accelerated for near-native performance

🌐 Web-based VNC access (port 6082)

🔑 RDP access (port 2223)

💾 Persistent storage volume

Prerequisites

Docker installed

KVM support on host machine

sudo privileges (for KVM device access)

Installation
# Clone the repository
git clone https://github.com/ParaNoob123/Windows-10
cd Windows-10

# Build the Docker image
docker build -t win10-vm .

# Run the container
docker run --privileged -p 6082:6082 -p 2223:2223 -v $PWD/vmdata:/data win10-vm

Access

VNC (Browser): http://localhost:6082/vnc.html

RDP Client: localhost:2223

Notes

First boot will launch the Windows 10 installer from the ISO.

After installation, the VM will boot directly from the virtual hard disk.

Your VM disk is stored inside ./vmdata and persists between container runs.
