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

- [Architecture Overview](docs/infrastructure.md)
- [Security: SSH Hardening, UFW, Fail2Ban](docs/security.md)
- [VPN Access](docs/vpn.md)
- [NFS Configuration](docs/nfs.md)
- [User and Group Management](docs/users.md)
- [Automation Scripts](docs/automation.md)
- [Monitoring and Logging](docs/monitoring.md)

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
