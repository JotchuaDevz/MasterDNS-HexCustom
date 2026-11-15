# MasterDNS · HexCustom

Servidor DNS-VPN basado en [MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN) con un gestor de menú para instalarlo y administrarlo en tu VPS. Se usa desde **HexCustom → SlowDNS → Motor MasterDNS**.

🇬🇧 [English](README.md)

---

## Requisitos

- VPS con Linux y **systemd** (Ubuntu, Debian, CentOS, AlmaLinux, Rocky…)
- Arquitectura **x86_64 (amd64)** o **ARM64 (aarch64)**
- Acceso **root**
- Puerto **53/UDP** abierto en el panel de tu proveedor
- Un dominio propio donde puedas crear registros DNS

## Instalación rápida

```bash
sudo apt update && sudo apt upgrade -y && sudo apt install -y wget iproute2 && wget -O install.sh https://raw.githubusercontent.com/JotchuaDevz/MasterDNS-HexCustom/refs/heads/main/install.sh && sudo bash install.sh
```

El script detecta la arquitectura, descarga el gestor y el servidor, y comienza la instalación. Te pedirá:

1. **Subdominio del túnel**, por ejemplo `v.tudominio.com`
2. **Cifrado**: XOR, ChaCha20 (recomendado), AES-128/192/256-GCM o None

Al terminar se muestran los datos para la app y los registros DNS que debes crear.

## Instalación manual

Sube a tu VPS el gestor y el servidor de tu arquitectura en la misma carpeta:

| Arquitectura | Gestor | Servidor |
| :--- | :--- | :--- |
| x86_64 | `masterdns-linux-amd64` | `masterdns-server-linux-amd64` |
| ARM64 | `masterdns-linux-arm64` | `masterdns-server-linux-arm64` |

```bash
chmod +x masterdns-linux-* masterdns-server-linux-*
sudo ./masterdns-linux-amd64
```

## Registros DNS

En el panel de tu dominio crea estos dos registros (reemplaza con tus datos):

| Tipo | Nombre | Valor |
| :--- | :--- | :--- |
| **A** | `ns.tudominio.com` | IP de tu VPS |
| **NS** | `v.tudominio.com` | `ns.tudominio.com` |

> Si usas Cloudflare, el registro **A** debe estar en modo **solo DNS** (nube gris), no en proxy.

La propagación puede tardar desde unos minutos hasta algunas horas.

## Configurar HexCustom

1. Agrega un servidor nuevo con el protocolo **SlowDNS**
2. En **Motor** elige **MasterDNS**
3. Llena los campos con los datos que mostró el gestor:

| Campo en la app | Valor |
| :--- | :--- |
| Clave de cifrado | La **Clave** del servidor |
| Dominio(s) del túnel | Tu subdominio, ej. `v.tudominio.com` |
| Resolver DNS | `8.8.8.8,1.1.1.1` o directo `IP_DEL_VPS:53` |
| Cifrado | El mismo que elegiste en el servidor |

Usuario y contraseña no son necesarios: la clave de cifrado es la autenticación.

## Menú del gestor

Después de instalar, escribe `masterdns` en cualquier momento:

```
1) Ver datos para la app        6) Cambiar cifrado (genera clave nueva)
2) Reiniciar servicio           7) Generar clave nueva
3) Detener servicio             8) Actualizar binario
4) Ver logs en vivo             9) Desinstalar
5) Cambiar dominio              0) Salir
```

## Comandos

| Comando | Acción |
| :--- | :--- |
| `masterdns` | Abre el menú (o instala si no existe) |
| `masterdns install` | Instalar o reinstalar |
| `masterdns info` | Ver datos para la app |
| `masterdns start` / `restart` | Iniciar o reiniciar |
| `masterdns stop` | Detener |
| `masterdns status` | Estado del servicio |
| `masterdns logs` | Logs en vivo |
| `masterdns uninstall` | Desinstalar |
| `masterdns --help` | Ayuda |

## Qué hace la instalación

- Instala el servidor en `/opt/masterdns` y genera la clave en `encrypt_key.txt`
- Libera el puerto 53 (desactiva el stub de `systemd-resolved` y detiene bind, dnsmasq, unbound, etc.)
- Abre 53/UDP en ufw, firewalld o iptables
- Aplica ajustes de red en `/etc/sysctl.d/99-masterdns.conf`
- Crea el servicio `masterdns` que arranca solo y se reinicia si se cae
- Instala el comando `/usr/local/bin/masterdns`

Al desinstalar se revierte todo, incluida la configuración original de `systemd-resolved`.

## Archivos

| Ruta | Contenido |
| :--- | :--- |
| `/opt/masterdns/masterdns-server` | Binario del servidor |
| `/opt/masterdns/server_config.toml` | Configuración |
| `/opt/masterdns/encrypt_key.txt` | Clave de cifrado |
| `/etc/systemd/system/masterdns.service` | Servicio |

## Problemas comunes

**El puerto 53 sigue ocupado.** Revisa qué lo usa con `ss -lnup | grep :53` y detén ese servicio.

**La app no conecta.**
- Verifica que el dominio, la clave y el cifrado sean iguales en el servidor y en la app.
- Revisa que el registro NS apunte a tu `ns.` y que el A apunte a la IP del VPS.
- Prueba primero con el resolver directo `IP_DEL_VPS:53`; si así funciona, el problema es la propagación DNS.
- Abre el puerto 53/UDP en el firewall del panel de tu proveedor (Oracle, AWS, Google Cloud, etc.).

**Ver qué está pasando.** `masterdns logs`

## Créditos

- Protocolo y servidor: [MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN) por MasterkinG32 (licencia MIT)
- Gestor e integración: HexCustom
