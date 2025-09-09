## Setting up Obsidian for note taking

Install Obsidian for the OS you are working on.

# INSTALLATION

## WINDOWS
- Make a folder `obsidian_vault`
- Properties > Sharing > `Everyone` > Enter your credentials
- Point your Obsidian vault into the shared folder.


## LINUX
### On the server to Obsidian centrally (only on one system):
```
sudo mkdir -p /srv/obsidian-vault
sudo chown -R nobody:nogroup /srv/obsidian-vault
sudo chmod -R 0777 /srv/obsidian-vault

// restart
sudo systemctl restart smbd
```
```
/etc/samba/smb.conf:

[obsidian]
   path = /srv/obsidian-vault
   browseable = yes
   writable = yes
   guest ok = no
   create mask = 0777
   directory mask = 0777
   oplocks = no
   level2 oplocks = no
```

# MOUNTING
### Mount from Linux:
```
mkdir -p ~/obsidian
mount -t cifs //server-ip/obsidian ~/obsidian -o username=youruser,password=yourpass,vers=3.0
```

### Mount from Windows:
- PowerShell (PS):
```
New-PSDrive -Name "O" -PSProvider FileSystem -Root "\\server-ip\obsidian" -Persist -Credential (Get-Credential)
```
- Throuh Network Discovery, identify the share and work through that vault folder on your end.
