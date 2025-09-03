# Windows 10 QEMU Virtual Machine in Docker Container

![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)
![QEMU](https://img.shields.io/badge/QEMU-FF6600?style=for-the-badge&logo=qemu&logoColor=white)
![Windows](https://img.shields.io/badge/Windows%2010-0078D6?style=for-the-badge&logo=windows&logoColor=white)

A lightweight **Windows 10** virtual machine running inside a Docker container using QEMU/KVM with web-based VNC access.  

## Features

- 🐳 Containerized Windows 10 VM  
- ⚡ KVM-accelerated for near-native performance  
- 🌐 Web-based VNC access (port **6082**)  
- 💻 RDP access (port **2223**) after installation  
- 💾 Persistent storage volume (keeps your installed system)  

## Prerequisites

- Docker installed  
- KVM support on host machine  
- `sudo` privileges (for KVM device access)  
- At least **8GB RAM** and **4 CPU cores** recommended  

## Installation

```bash
# Clone the repository
git clone https://github.com/ParaNoob123/Windows-10
cd Windows-10

# Build the Docker image
docker build -t win10-vm .

# Run the container
docker run --privileged -p 6082:6082 -p 2223:2223 -v $PWD/vmdata:/data win10-vm
