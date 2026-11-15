#!/usr/bin/env bash
set -e
BASE="${MASTERDNS_URL:-https://raw.githubusercontent.com/JotchuaDevz/MasterDNS-HexCustom/refs/heads/main}"
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root: sudo bash $0"; exit 1; }
case "$(uname -m)" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Arquitectura no soportada: $(uname -m)"; exit 1 ;;
esac
command -v curl >/dev/null 2>&1 || { apt-get update -qq && apt-get install -y -qq curl || yum install -y -q curl || dnf install -y -q curl; } >/dev/null 2>&1
echo " ➜ Arquitectura: $ARCH"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo " ➜ Descargando gestor y servidor..."
curl -fL --retry 3 -# -o "$TMP/masterdns" "$BASE/masterdns-linux-$ARCH"
curl -fL --retry 3 -# -o "$TMP/masterdns-server-linux-$ARCH" "$BASE/masterdns-server-linux-$ARCH"
chmod +x "$TMP/masterdns" "$TMP/masterdns-server-linux-$ARCH"
MASTERDNS_URL="$BASE" "$TMP/masterdns" install </dev/tty
