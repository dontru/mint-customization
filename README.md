# Mint Customization

Linux Mint Live CD customization tool

### Resources
- https://help.ubuntu.com/community/LiveCDCustomization
- https://community.linuxmint.com/tutorial/view/1784

### Usage

Place files in a separate directory
```
project
|-- build.sh
|-- config.sh
|-- linuxmint-19-cinnamon-64bit-v2.iso
```

Put your customizations in *config.sh*. For example:
```bash
#!/bin/bash

apt update

apt install -y git
wget -O atom-amd64.deb "https://atom.io/download/deb"
dpkg -i atom-amd64.deb

apt upgrade -y
```

Run build.sh
```bash
sudo ./build.sh linuxmint-19-cinnamon-64bit-v2.iso
```
