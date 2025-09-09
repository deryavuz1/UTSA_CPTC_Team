# INITIAL ENUMERATION STEPS FOR ALL MACHINES

When you get access to your machine, we will assign CIDR ranges to each person and these will be ran locally on your jumpbox machine.

DO NOT SCAN ANY OT NETWORK IPs, TRIPLE CHECK TO ENSURE THE RANGES DO NOT INCLUDE OT.

### Ping Sweep

Ensure to exclude the OT subnet by creating an `exclude_ot.txt` file.

Put the live IPs into a list OR use the subnet itself:

`nmap -sn 192.168.1.0/24 --exclude-file exclude_ot.txt -oG subnet_1.gnmap`
`cat subnet_1.gnmap | grep "Up" | cut -d " " -f2 > live_hosts_<subnet>.txt`

### Service and Port Scans

Ensure to exclude the OT subnet by creating an `exclude_ot.txt` file.

With the live IPs identified, run service AND port scans and save output. COPY and PASTE the scan output with open ports and services into the OBSIDIAN NOTES | GOOGLE DOC with filename format: `<IP>.nmap`

`nmap -iL live_hosts_<subnet>.txt -p- -sV -T4 -oN detailed_scan_<subnet>.txt`

