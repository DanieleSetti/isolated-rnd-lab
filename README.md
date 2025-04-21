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
