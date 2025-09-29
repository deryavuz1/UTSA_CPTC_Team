#!/usr/bin/env bash
set -euo pipefail

# Usage: ./NmapScan.sh <target_range> <exclude_file> <label> [JOBS]
if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <target_range> <exclude_file> <label> [JOBS]"
  exit 1
fi

TARGET="$1"
EXCLUDE="$2"
LABEL="$3"
JOBS="${4:-2}"

command -v sudo >/dev/null 2>&1 || { echo "ERROR: sudo not found."; exit 1; }
echo "[*] Validating sudo privileges…"
sudo -v || { echo "ERROR: sudo auth failed."; exit 1; }
( while true; do sleep 60; sudo -n true 2>/dev/null || exit 0; done ) & SUDO_KEEPALIVE=$!
trap 'kill $SUDO_KEEPALIVE 2>/dev/null || true' EXIT

[[ -f "$EXCLUDE" ]] || { echo "ERROR: Exclude file '$EXCLUDE' not found."; exit 1; }

ROOT="scan-${LABEL}"
PING_DIR="${ROOT}/01_ping_sweep"
TCP_DIR="${ROOT}/02_tcp_full_ports_services"
VULN_DIR="${ROOT}/03_vuln_checks_tcp_open_ports"
UDP_DIR="${ROOT}/04_udp_top100"
mkdir -p "$PING_DIR" "$TCP_DIR" "$VULN_DIR" "$UDP_DIR"

SUBNET_GNMAP="${PING_DIR}/subnet_${LABEL}.gnmap"
LIVE_LIST="${PING_DIR}/live_hosts_${LABEL}.txt"

echo "[*] Ping sweep (excluding OT from ${EXCLUDE}) → ${SUBNET_GNMAP}"
sudo nmap -sn "$TARGET" --excludefile "$EXCLUDE" -oG "$SUBNET_GNMAP"
awk '/Up$/{print $2}' "$SUBNET_GNMAP" | sort -V | uniq > "$LIVE_LIST"

LC=$(wc -l < "$LIVE_LIST" || echo 0)
echo "[*] Live hosts: $LC"
[[ "$LC" -gt 0 ]] || { echo "[!] None up. Exiting."; exit 0; }

PORT_SCAN_FLAGS="-p- -sV -T4"
VULN_SCRIPTS="vuln,vulners"
UDP_FLAGS="-sU --top-ports 100 -T4 -v" 

echo "[*] Starting per-host scans with ${JOBS} concurrent job(s)…"
echo "[*] Outputs:"
echo "    - TCP : ${TCP_DIR}/<IP>.nmap"
echo "    - Vuln: ${VULN_DIR}/<IP>_vuln.nmap"
echo "    - UDP : ${UDP_DIR}/<IP>_udp.nmap"

scan_host() {
  local ip="$1"
  local tcp_note="${TCP_DIR}/${ip}.nmap"
  local vuln_note="${VULN_DIR}/${ip}_vuln.nmap"
  local udp_note="${UDP_DIR}/${ip}_udp.nmap"

  echo
  echo "===== [${ip}] Full TCP scan ${PORT_SCAN_FLAGS} ====="
  sudo nmap ${PORT_SCAN_FLAGS} --excludefile "$EXCLUDE" -oN - "$ip" | tee "${tcp_note}"

  local ports
  ports="$(awk '/^[0-9]+\/tcp/ && /open/ {print $1}' "${tcp_note}" | cut -d/ -f1 | paste -sd, -)"

  if [[ -n "${ports}" ]]; then
    {
      echo
      echo "===== [${ip}] Vulnerability scripts on open ports (${ports}) ====="
    } | tee "${vuln_note}"

    sudo nmap -sV --script="${VULN_SCRIPTS}" -p "${ports}" --excludefile "$EXCLUDE" -oN - "$ip" | tee -a "${vuln_note}"
  else
    echo "===== [${ip}] No open TCP ports found to run vuln scripts =====" | tee "${vuln_note}"
  fi

  echo
  echo "===== [${ip}] UDP scan ${UDP_FLAGS} ====="
  sudo nmap ${UDP_FLAGS} --excludefile "$EXCLUDE" -oN - "$ip" | tee "${udp_note}"

  echo "===== [${ip}] Done. Files:"
  echo "      TCP : ${tcp_note}"
  echo "      VULN: ${vuln_note}"
  echo "      UDP : ${udp_note}"
}

while read -r ip; do
  while [[ $(jobs -rp | wc -l) -ge $JOBS ]]; do sleep 0.2; done
  scan_host "$ip" &
done < "$LIVE_LIST"

wait
echo
echo "[✓] Complete."
echo "Folders:"
echo "  ${PING_DIR}/  -> subnet_${LABEL}.gnmap, live_hosts_${LABEL}.txt"
echo "  ${TCP_DIR}/   -> <IP>.nmap (ports & services)"
echo "  ${VULN_DIR}/  -> <IP>_vuln.nmap (vuln/vulners on open TCP ports)"
echo "  ${UDP_DIR}/   -> <IP>_udp.nmap (UDP top-100)"
