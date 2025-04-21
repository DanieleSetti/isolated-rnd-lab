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
- [🧰 Initial VM Setup and Networking](#-initial-vm-setup-and-networking)
- [👥 User and Group Management](#-user-and-group-management)
- [🔌 NFS Configuration](#-nfs-configuration-for-shared-directory-access-between-server-and-client)
- [🧱 VPN and Bastion Server Setup](#-vpn-and-bastion-server-setup)
- [📁 UFW Configuration and Troubleshooting](#-ufw-configuration-and-troubleshooting-documentation)
- [🔐 Basic SSH Hardening](#-basic-ssh-hardening)
- [📜 Useful Scripts](#-useful-scripts)


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


## 🗂 NFS Configuration for Shared Directory Access between Server and Client

This section describes the setup and configuration of NFS (Network File System) to enable shared access between the server and client machines.

### Why NFS?

NFS (Network File System) is a protocol that allows you to mount directories from a remote machine as if they were local. I chose NFS because it's an open-source solution that doesn't require licenses and is well-suited for file sharing between Linux servers. It is widely used in small to medium teams, such as our development team.

### Connection Issues

During the initial attempt to connect to the server via NFS, I encountered a problem where the server and client were on different networks (using different network adapters). The server used a Host-Only Adapter, while the client used NAT. This caused the machines to be unable to communicate with each other.

### Solution to the Connection Problem

To resolve the issue, I changed the client's network adapter to Host-Only, similar to the server's configuration. This created a private network where both machines could interact with each other. Once this was done, I was able to successfully connect from the client to the server and mount the necessary directory.

### NFS Server Configuration

1. **Install NFS Server:**
   On the server, I installed the necessary NFS packages:

2. **Create Export Directory:**
   I created the directory to be shared (`/home/dev`) and set the appropriate permissions:

   ```bash
   sudo mkdir /home/dev
   sudo chown root:devteam /home/dev
   sudo chmod 2770 /home/dev
   ```

3. **Export the Directory:**
   I edited the `/etc/exports` file to allow the client access:

   ```bash
   /home/dev 192.168.56.0/24(rw,sync,no_subtree_check)
   ```

4. **Restart NFS Service:**
   Finally, I restarted the NFS service to apply the changes:

   ```bash
   sudo exportfs -ra
   sudo systemctl restart nfs-kernel-server
   ```

### NFS Client Configuration

1. **Install NFS Client:**
   On the client machine, I installed the necessary packages to work with NFS:

2. **Mount the Remote Directory:**
   I mounted the remote directory from the server:

   ```bash
   sudo mount 192.168.56.10:/home/dev /mnt
   ```

3. **Automate Mounting with /etc/fstab:**
   To ensure the directory is automatically mounted on system boot, I added the following line to the `/etc/fstab` file:

   ```bash
   192.168.56.10:/home/dev /mnt nfs defaults 0 0
   ```

### User and Group Creation on Client

To restrict access to the shared directory to only the `devteam` group (including users `john`, `bob`, and `kim`), I created the users and group on the client machine:

1. **Create Users:**

   ```bash
   sudo useradd -m john
   sudo passwd john
   sudo useradd -m bob
   sudo passwd bob
   sudo useradd -m kim
   sudo passwd kim
   ```

2. **Create Group:**

   ```bash
   sudo groupadd devteam
   sudo usermod -aG devteam john
   sudo usermod -aG devteam bob
   sudo usermod -aG devteam kim
   ```

### Verifying the Configuration

After setting up NFS and creating the necessary users and groups, I verified access to the mounted directory on the client. I created a test file through the `john` user in the mounted directory and confirmed that the file was updated on the server:

```bash
sudo -u john touch /mnt/testfile.txt
ls -l /mnt
```

Now, only users from the `devteam` group can work with files in the `/home/dev` directory, and access for other users is restricted.

### Conclusion

By configuring NFS, I enabled secure file sharing between the server and client machines. I used a Host-Only Adapter to create a private network, ensuring that only the `devteam` group has access to the shared directory. The setup is now working correctly, and I can securely manage files within the shared directory on the server.

### 🛠 How to Fix the "Illegal Port" Error During NFS Mounting

**Problem:**  
The NFS server refused mount requests from the client, showing the error `refused mount request ... illegal port`. This happens because by default, the `rpc.mountd` service on the server allows connections only from privileged ports (below 1024), while the client uses a random port above 1024.

**Solution:**  
To allow connections from non-privileged ports, I added the `insecure` option in the `/etc/exports` file on the server:

```bash
/home/dev 192.168.56.0/24(rw,sync,no_subtree_check,insecure)
```

After modifying the file, I applied the changes by running:

```bash
sudo exportfs -ra
```

Finally, I confirmed that the export was applied:

```bash
sudo exportfs -v
```



## 🧱 VPN and Bastion Server Setup

### VPN + Bastion Host

<pre>
     ┌────────────┐
     │  Your PC   │
     └────┬───────┘
          │
          ▼
 ┌──────────────────┐           ┌────────────────────┐
 │  Bastion Host    │ <───────> │     Server2        │
 │ (VPN + SSH)      │           │  (SSH only via VPN)│
 └──────────────────┘           └────────────────────┘
</pre>

---

### 🔧 Objective

The goal was to set up a secure internal infrastructure consisting of two virtual machines:

- **infra-server**: Acts as the bastion host (entry point) and dev server.
- **server2**: A protected internal machine, accessible only via VPN.

### ✅ What Was Done

1. **Created the second virtual machine (server2)** based on Ubuntu live server, with a minimal set of packages.
   - Static IP assigned via host-only interface: `192.168.56.20`.

2. **Installed and configured WireGuard:**
   - On **infra-server**, I set up the WireGuard server with IP `10.10.0.1/24`.
   - On **server2**, I set up the WireGuard client with IP `10.10.0.2/24`.
   - Enabled routing between VPN interfaces.

3. **Modified SSH configuration on server2:**
   - SSH is now configured to listen only on the WireGuard interface (`10.10.0.2`).
   - The SSH port is closed for NAT and host-only interfaces.

4. **Testing:**
   - From infra-server (via VPN), I was able to connect to server2 over SSH.
   - Access from the host or other machines without VPN is not possible — the connection hangs (no route or timeout).

### 🔐 Why This Approach?

**Security:**
- **Server2** is not directly accessible — even if an attacker knows its IP and SSH is enabled, they cannot access it without a VPN connection.
- This reduces the attack surface and simulates a real production environment.

**Centralized Access:**
- All connections to the infrastructure pass through a single controlled server (infra-server).
- This allows logging, applying access policies, and simplifying security management.

### 💡 Conclusion

We have implemented a classic scheme: **bastion → VPN → internal network**. In production, such bastion servers are located in the DMZ or edge segments. All internal services are isolated from the external world. 

As a result, even if a host or client is compromised, without access to the bastion and VPN, the infrastructure remains isolated.

### ❗ Problem: WireGuard Tunnel Doesn't Work Until the Second Side Sends the First Packet

**Symptoms:**
- SSH connection to **Server2** from **infra-server** does not work.
- After pinging from **Server2** to **infra-server**, the connection starts working.
- Logs show "No route to host" error.

**Reason:**
- WireGuard operates over UDP and does not establish a persistent connection (unlike TCP). Until one side sends the first packet, the other side doesn't know where to send the response.
- This is especially critical if:
  - Peers are behind NAT (e.g., VBox NAT or internal networks).
  - One node does not listen on the port (no `ListenPort`).
  - No active traffic between peers.

WireGuard stores the endpoint (peer address) only after a successful handshake. Without it, packets are lost.

### ✅ Solution

1. **Ensure both peers have a `ListenPort` set:**
   On **Server2** (if it's supposed to accept connections):

   ```bash
   [Interface]
   Address = 10.10.0.2/24
   PrivateKey = <PRIVATE_KEY>
   ListenPort = 51821  
   
   [Peer]
   PublicKey = <PUB_INFRA_SERVER>
   Endpoint = 192.168.56.10:51820
   AllowedIPs = 10.10.0.1/32
   PersistentKeepalive = 15

   `ListenPort` is required for the kernel to create a UDP socket and listen for incoming connections.

2. **Add `PersistentKeepalive` on the side that should maintain the connection:**
   On **infra-server**:

   ```bash
   [Peer]
   PublicKey = <PUB_SERVER2>
   AllowedIPs = 10.10.0.2/32
   PersistentKeepalive = 15
   ```

   This ensures that **infra-server** sends a packet every 15 seconds, keeping the connection alive, even if **Server2** is silent.

### 📌 Diagnostics

To check the status of the WireGuard tunnel:

```bash
sudo wg show
```

Look for the `latest handshake` field. If it's missing, the peers haven't connected, and the tunnel is "dead."

### 💡 Conclusion

WireGuard is reliable, but it requires an understanding of its mechanics:
- No TCP connection → no handshake → no route.
- **PersistentKeepalive** solves this problem.
- Internal networks and NAT make this issue especially noticeable.

Now the tunnel works reliably and does not require manual pinging.


## 📁 UFW Configuration and Troubleshooting Documentation

### Introduction

**UFW (Uncomplicated Firewall)** is a tool used to configure and manage the firewall on Linux. In this project, UFW is used to manage access to the server and ensure security by restricting access to services on specific ports.

### 1. Installing and Enabling UFW

#### Installing UFW

On **server2**, install UFW with the following command:

```bash
sudo apt install ufw
```

#### Enabling UFW

After installation, enable UFW with the command:

```bash
sudo ufw enable
```

**Important:** When enabling the firewall, a warning will be displayed that SSH connectivity might be disrupted. Ensure that the firewall settings allow access on the required ports.

### 2. Configuring Rules for SSH Access Over VPN

To ensure SSH access to the server is only possible when connected via VPN, configure the following rules:

#### Allow SSH Connections on the `wg0` Interface

#### UFW Configuration Parameters

To check the current firewall rules, use the command:

```bash
sudo ufw status verbose
```

Example output:

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
51820/udp                  ALLOW IN    Anywhere
Anywhere on wg0            ALLOW IN    Anywhere
22/tcp on wg0              ALLOW IN    Anywhere
51820/udp (v6)             ALLOW IN    Anywhere (v6)
Anywhere (v6) on wg0       ALLOW IN    Anywhere (v6)
22/tcp (v6) on wg0         ALLOW IN    Anywhere (v6)
```

### 3. Troubleshooting SSH Connectivity After Enabling UFW

After enabling UFW and adding rules, SSH connectivity might not work if the firewall rules are not correctly set. If you are unable to connect to the server via SSH, the following reasons might apply:

#### Problem: SSH Connection Error

**Causes:**
- UFW rules do not allow access on port 22 via the `wg0` interface.
- A firewall is blocking the connection.
- The VPN connection is not established or is unstable.

#### Solution:

Add the necessary rules to allow SSH over the VPN:

```bash
sudo ufw allow in on wg0 to any port 22 proto tcp
sudo ufw enable
```

#### Final UFW Configuration

**Logging:** on (low)

**Default:** deny (incoming), allow (outgoing), disabled (routed)

**New profiles:** skip

**To**                         | **Action**  | **From**
-------------------------------|-------------|---------------------
2049/tcp                        | ALLOW IN    | 192.168.56.0/24
2049/udp                        | ALLOW IN    | 192.168.56.0/24
111/tcp                         | ALLOW IN    | 192.168.56.0/24
111/udp                         | ALLOW IN    | 192.168.56.0/24
22/tcp                          | ALLOW IN    | 192.168.56.0/24
22/tcp                          | ALLOW IN    | 192.168.56.1
51820/udp on enp0s8             | ALLOW IN    | 192.168.56.20

**To**                         | **Action**  | **From**
-------------------------------|-------------|---------------------
Anywhere                       | ALLOW OUT   | Anywhere on wg0
192.168.56.10 51820/udp        | ALLOW OUT   | Anywhere on enp0s8
192.168.56.20 51820/udp        | ALLOW OUT   | Anywhere on enp0s8*


## 🔐 Basic SSH Hardening

### Objective

Minimize the risk of unauthorized access to the server via SSH within the local network, even when password authentication is enabled.

---

### 1. Disable Root Login via SSH

**Why:**  
The `root` account is a common target for attacks. Even with a strong password, direct login as root should be disabled to reduce the attack surface.

**How:**  
Edit the SSH daemon configuration file `/etc/ssh/sshd_config` and add or modify the following line:

```bash
PermitRootLogin no
```

---

### 2. Allow SSH Access for Specific Users Only

**Why:**  
Restricting SSH access to a specific user (e.g., `admin`) prevents login attempts with other usernames, even if their credentials are compromised.

**How:**  
In the same `/etc/ssh/sshd_config` file, specify the allowed user(s):

```bash
AllowUsers admin
```

💡 Any login attempts from other usernames will be rejected before password verification is even attempted.

---

### 3. Set Up Fail2Ban

**Why:**  
Fail2Ban provides protection against brute-force attacks by automatically banning IP addresses that repeatedly fail to authenticate.

**How:**  
Install and configure Fail2Ban:

```bash
sudo apt install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

Edit the file `/etc/fail2ban/jail.local` and configure the `sshd` section (or add it manually):

```ini
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 60  # temporary ban time in seconds (adjust as needed)
```

Start and check the status:

```bash
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd
```

---

⚠️ **Note:**  
At this stage, SSH key-based authentication is **not yet configured** — login is still password-based.

In the future, it is recommended to fully disable password authentication (`PasswordAuthentication no`) and switch to SSH key authentication for enhanced security.

Currently, this is not critical, as:
- The server is located within a **private LAN**.
- Additional protections are in place via **UFW** and **Fail2Ban**.


## 📜 Useful Scripts

These scripts automate typical sysadmin tasks in the isolated R&D environment.

- [`update_system.sh`](./scripts/update_system.sh) – System update script with logging and cron scheduling.
- [`setup_nfs.sh`](./scripts/setup_nfs.sh) – Configure and export NFS shares to internal clients.
- [`add_user.sh`](./scripts/add_user.sh) – Add new users with proper permissions and home directories.
- [`vpn_setup.sh`](./scripts/vpn_setup.sh) – Generate VPN credentials and .ovpn config for new clients.

See each script for in-line documentation. All scripts are meant to be run as `root`.
