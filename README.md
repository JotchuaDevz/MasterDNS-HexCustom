# MasterDNS · HexCustom

DNS-VPN server based on [MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN) with a menu-driven manager to install and run it on your VPS. Use it from **HexCustom → SlowDNS → MasterDNS engine**.

🇪🇸 [Español](README_ES.md)

---

## Requirements

- Linux VPS with **systemd** (Ubuntu, Debian, CentOS, AlmaLinux, Rocky…)
- **x86_64 (amd64)** or **ARM64 (aarch64)** architecture
- **root** access
- Port **53/UDP** open in your provider's panel
- Your own domain where you can create DNS records

## Quick install

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/JotchuaDevz/MasterDNS-HexCustom/refs/heads/main/install.sh)
```

The script detects the architecture, downloads the manager and the server, and starts the installation. It will ask for:

1. **Tunnel subdomain**, for example `v.yourdomain.com`
2. **Encryption**: XOR, ChaCha20 (recommended), AES-128/192/256-GCM or None

When it finishes, it shows the data for the app and the DNS records you need to create.

## Manual install

Upload the manager and the server for your architecture to the same folder on your VPS:

| Architecture | Manager | Server |
| :--- | :--- | :--- |
| x86_64 | `masterdns-linux-amd64` | `masterdns-server-linux-amd64` |
| ARM64 | `masterdns-linux-arm64` | `masterdns-server-linux-arm64` |

```bash
chmod +x masterdns-linux-* masterdns-server-linux-*
sudo ./masterdns-linux-amd64
```

## DNS records

In your domain's panel, create these two records (replace with your data):

| Type | Name | Value |
| :--- | :--- | :--- |
| **A** | `ns.yourdomain.com` | Your VPS IP |
| **NS** | `v.yourdomain.com` | `ns.yourdomain.com` |

> If you use Cloudflare, the **A** record must be **DNS only** (grey cloud), not proxied.

Propagation can take from a few minutes to a few hours.

## Set up HexCustom

1. Add a new server with the **SlowDNS** protocol
2. Under **Engine**, choose **MasterDNS**
3. Fill in the fields with the data shown by the manager:

| App field | Value |
| :--- | :--- |
| Encryption key | The server's **Key** |
| Tunnel domain(s) | Your subdomain, e.g. `v.yourdomain.com` |
| DNS resolver | `8.8.8.8,1.1.1.1` or direct `VPS_IP:53` |
| Encryption | The same one you chose on the server |

Username and password are not needed: the encryption key is the authentication.

## Manager menu

After installing, type `masterdns` at any time:

```
1) Show app data                6) Change encryption (new key)
2) Restart service              7) Generate new key
3) Stop service                 8) Update binary
4) Live logs                    9) Uninstall
5) Change domain                0) Exit
```

The menu itself is in Spanish; the options above are a translation.

## Commands

| Command | Action |
| :--- | :--- |
| `masterdns` | Opens the menu (or installs if missing) |
| `masterdns install` | Install or reinstall |
| `masterdns info` | Show app data |
| `masterdns start` / `restart` | Start or restart |
| `masterdns stop` | Stop |
| `masterdns status` | Service status |
| `masterdns logs` | Live logs |
| `masterdns uninstall` | Uninstall |
| `masterdns --help` | Help |

## What the installer does

- Installs the server in `/opt/masterdns` and generates the key in `encrypt_key.txt`
- Frees port 53 (disables the `systemd-resolved` stub and stops bind, dnsmasq, unbound, etc.)
- Opens 53/UDP in ufw, firewalld or iptables
- Applies network tuning in `/etc/sysctl.d/99-masterdns.conf`
- Creates the `masterdns` service, which starts on boot and restarts if it crashes
- Installs the `/usr/local/bin/masterdns` command

Uninstalling reverts everything, including the original `systemd-resolved` configuration.

## Files

| Path | Content |
| :--- | :--- |
| `/opt/masterdns/masterdns-server` | Server binary |
| `/opt/masterdns/server_config.toml` | Configuration |
| `/opt/masterdns/encrypt_key.txt` | Encryption key |
| `/etc/systemd/system/masterdns.service` | Service |

## Troubleshooting

**Port 53 is still busy.** Check what uses it with `ss -lnup | grep :53` and stop that service.

**The app does not connect.**
- Make sure the domain, key and encryption match on the server and in the app.
- Check that the NS record points to your `ns.` host and the A record points to the VPS IP.
- Try the direct resolver `VPS_IP:53` first; if that works, the issue is DNS propagation.
- Open port 53/UDP in your provider's panel firewall (Oracle, AWS, Google Cloud, etc.).

**See what is happening.** `masterdns logs`

## Credits

- Protocol and server: [MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN) by MasterkinG32 (MIT license)
- Manager and integration: HexCustom
