
# Manual Guide to GhostWriter

- AFTER INITIAL SETUP, RUN THIS ON THE CENTRAL MACHINE THAT GHOSTWRITER SHOULD BE ON.
- ENSURE TO RUN THE `setup-script.sh` BEFORE RUNNING THIS SO THE TOOLS ARE IN PLACE. 
- OTHER MACHINES WILL ACCESS THIS THROUGH PORT FORWARDING:
    `sudo ssh -N -L 80:localhost:80 <user>@<IP_OF_GHOSTWRITER_MACHINE>`



read -p "This script is only for a singular machine to run Ghostwriter on - ensure that you've run the \"setup-script.sh\" before running this script. Other machines will access the Ghostwriter  interface on this through port forwarding to collaborate."

sudo apt install -y \
	docker.io \
	docker-compose \
	openjdk-11-jdk

# Ghostwriter
echo -e "\n[*] Installing Ghostwriter..."
mkdir -p ~/tools/Ghostwriter/
git clone https://github.com/GhostManager/Ghostwriter.git ~/tools/ghostwriter-cli-linux
sudo ~/tools/Ghostwriter/ghostwriter-cli-linux install

echo -e '\nGhostwriter is ready!\n'
tmp=$(~/tools/Ghostwriter/ghostwriter-cli-linux config get admin_password)
passwd=$(echo $tmp | cut -d" " -f10)
echo -e "Credentials:\nUsername: admin\nPassword: $passwd"
echo -e "\nGive your team this command to access Ghostwriter remotely:\nsudo ssh -N -L 80:localhost:80 user@<IP>"
echo -e "\nGhostwriter will be hosted at https://localhost/"

echo -e "\n[*] Installing Sublime text..."
wget https://download.sublimetext.com/sublime-text_build-3211_amd64.deb
sudo dpkg -i sublime-text_build-3211_amd64.deb