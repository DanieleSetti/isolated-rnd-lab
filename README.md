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
```

#### 🔌 Result
The server received internet access through `enp0s3` (NAT).

The static IP `192.168.56.10` was assigned to `enp0s8`.

From the host machine, SSH access became available

This completed the initial setup of the primary server, which is now ready for further roles such as user management and file sharing.

## 👥 User and Group Management

This section covers the creation of developer users, hardening of the admin account, and configuration of a shared working directory for collaborative access.

### 🧑‍💻 User Creation

Three standard users (`john`, `bob`, and `kim`) were created to simulate a development team environment:

- Created using `adduser`, each with a default home directory.
- A common password was temporarily assigned for simplicity.

### 🔐 Admin User Hardening

To restrict access to the administrative user's data:

```bash
chmod 700 /home/admin
```

This ensures that only the `admin` user has access to their home directory, improving overall security.

### 🧑‍🤝‍🧑 Group Setup: `devteam`

A new group `devteam` was created to represent the developer team:

```bash
sudo groupadd devteam
```

All three developer users were added to this group using:

```bash
sudo usermod -aG devteam <username>
```

This allows for flexible permissions management across the team.

### 📂 Shared Working Directory

To support collaboration, a shared directory `/home/dev` was created and configured:

```bash
sudo mkdir /home/dev
sudo chown root:devteam /home/dev
sudo chmod 2770 /home/dev
```

- Ownership was set to `root:devteam`.
- The `2770` permission ensures:
  - Only users in the `devteam` group can access the directory.
  - New files created inside inherit the group (`setgid` bit).

This setup provides a secure and organized environment for internal team collaboration.
