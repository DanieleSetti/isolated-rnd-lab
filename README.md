# 🛡️ Secure LAN Infrastructure for R&D Department

This project simulates a secure, isolated IT infrastructure for a Research & Development (R&D) team. It is designed as a **realistic sysadmin lab**, with strict access control, internal network services, and basic automation.

The infrastructure includes:
- Two servers (infra-server and VPN gateway)
- Client machines (developers)
- VPN access, SSH hardening, and UFW firewall
- NFS for shared user directories
- Basic automation and monitoring tools

> ⚠️ This project is intended for learning and demonstration purposes only.

---

## 📚 Table of Contents


## ⚙️ Scripts

| Script              | Purpose                          |
|---------------------|----------------------------------|
| `add_user.sh`       | Add a new user + SSH key + NFS   |
| `vpn_setup.sh`      | Generate VPN client config       |
| `setup_nfs.sh`      | Configure NFS exports            |
| `update_system.sh`  | Update system packages           |
| `logrotate_setup.sh`| Set up log rotation (optional)   |

---

## 🧠 Motivation

This project demonstrates:
- How to isolate a department from the rest of the network
- Controlled access via VPN and bastion host
- Secure user provisioning and access control
- Simple, maintainable automation with Bash
- Monitoring internal infrastructure with minimal tools

---

## 🚀 Goals

- Learn to structure and secure real-world systems
- Create documentation that mirrors production-level clarity
- Use as portfolio to apply for junior sysadmin roles

---

## 🧰 Initial VM Setup and Networking

The first virtual machine acts as the core infrastructure node — responsible for user management, file sharing, and general control of the internal R&D network.

### 🧱 Base OS Installation

- Ubuntu Server LTS was used (recommended: 20.04 or 22.04).
- A user account named `admin` was created during installation.
- OpenSSH Server was installed.
- The VM was configured to use a static internal IP and support internet access.

### 🌐 Network Configuration (Dual Interface)

The goal was to configure two separate network interfaces:

- `enp0s3` — NAT (for internet access)
- `enp0s8` — Host-Only Adapter (for access from the host system and internal lab)

#### ⚠️ Problem

By default, `enp0s8` did not receive an IP address, and the default Netplan config only included `enp0s3` with DHCP.

#### ✅ Solution

Manually edited the Netplan configuration file `/etc/netplan/50-cloud-init.yaml` to define both interfaces:

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true

    enp0s8:
      dhcp4: false
      addresses:
      - 192.168.56.10/24
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1

🔌 Result
The server received internet access through enp0s3 (NAT).

The static IP 192.168.56.10 was assigned to enp0s8.

From the host machine, SSH access became available:
