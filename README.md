🪟 Windows 10 QEMU Virtual Machine in Docker

A lightweight Windows 10 virtual machine running inside a Docker container using QEMU/KVM for near-native performance.
Access it directly from your browser with noVNC or via RDP/SSH.

✨ Features

🐳 Containerized Windows 10 VM

⚡ KVM-accelerated for faster virtualization

🌐 Web-based VNC access (port 6082)

🔑 RDP passthrough (port 2223)

💾 Persistent storage (saved in ./vmdata)

📦 Prerequisites

Docker installed

Host machine must support KVM (check with egrep -c '(vmx|svm)' /proc/cpuinfo)

sudo privileges (for /dev/kvm access)

At least 4 GB RAM recommended (Windows will crawl on less)

👤 VM Default User

During install you will set up your own Windows account.
(Default disk is blank until first install.)

🚀 Installation
# Clone the repository
git clone https://github.com/ParaNoob123/Windows-10
cd Windows-10

# Build the Docker image
docker build -t win10-vm .

# Run the container
docker run --privileged -p 6082:6082 -p 2223:2223 -v $PWD/vmdata:/data win10-vm

🌐 Accessing the VM

Browser (VNC) → Open:

http://localhost:6082/vnc.html


RDP (after install) → Connect to localhost:2223 using Remote Desktop Client.

💾 Persistent Storage

Your VM disk (win10.img) is stored inside ./vmdata.
This means your Windows install and files are preserved even if you stop/restart the container.

⚠️ Notes

First boot will load the Windows 10 installer from ISO.

After completing installation, VM will boot from virtual hard disk automatically.

If you’re running in GitHub Codespaces or other low-RAM environments (2GB/4GB), Windows 10 may be too heavy. In that case, consider using Tiny11 (lightweight Windows 10 build).

🛠️ Commands Cheat Sheet
# Stop all running containers
docker stop $(docker ps -q)

# Delete container (data kept in ./vmdata)
docker rm <container_id>

# Rebuild image from scratch
docker build -t win10-vm .
