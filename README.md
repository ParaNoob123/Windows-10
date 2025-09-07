# 🪟 Pre-Installed Windows 10 (or Tiny10) VM in Docker

![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)
![QEMU](https://img.shields.io/badge/QEMU-FF6600?style=for-the-badge&logo=qemu&logoColor=white)
![Windows 10](https://img.shields.io/badge/Windows%2010-0078D6?style=for-the-badge&logo=windows&logoColor=white)

Boot directly into a fully installed **Windows 10** or **Tiny10** VM using Docker and QEMU/KVM. No installation steps required!

---

## Features

-  **Pre-configured Windows VM** (Pro 22H2 or lightweight Tiny10)
-  Boots instantly—no setup needed
-  **VNC access** via browser (port 6082)
-  **RDP access** (port 2223)
-  Persistent disk stored in `./vmdata`

---

## Prerequisites

- Docker installed with **KVM virtualization support**
- `sudo` access for `/dev/kvm`
- Recommended setup: **4 GB RAM**, **2+ CPU cores**

---

## Installation

```bash
git clone https://github.com/ParaNoob123/Windows-10
cd Windows-10

docker build -t win10-pre .
docker run --privileged -p 6082:6082 -p 2223:2223 -v $PWD/vmdata:/data win10-pre
