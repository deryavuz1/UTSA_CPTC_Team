## Setting up Obsidian for note taking

### On the server to Obsidian centrally (only on one system):
```
sudo mkdir -p /srv/obsidian-vault
sudo chown -R nobody:nogroup /srv/obsidian-vault
sudo chmod -R 0777 /srv/obsidian-vault

// restart
sudo systemctl restart smbd
```



### Mount from Linux:
```
mkdir -p ~/obsidian
mount -t cifs //server-ip/obsidian ~/obsidian -o username=youruser,password=yourpass,vers=3.0
```

### Mount from Windows (PS):
```
New-PSDrive -Name "O" -PSProvider FileSystem -Root "\\server-ip\obsidian" -Persist -Credential (Get-Credential)
```
