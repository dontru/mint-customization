# Mint Customization

Linux Mint Live CD customization tool

### Resources
- https://help.ubuntu.com/community/LiveCDCustomization
- https://community.linuxmint.com/tutorial/view/1784

### Usage

1\. Clone && make
```bash
git clone https://github.com/dontru/mint-customization.git
cd mint-customization
make
cd build
```

2\. Copy the iso file to the *build* directory

3\. Put your customizations in *build/config.sh*

4\. Run *build/build.sh*
```bash
sudo ./build.sh
```

### Example config.sh
```bash
#!/bin/bash

apt update

apt install -y git
wget -O atom-amd64.deb "https://atom.io/download/deb"
dpkg -i atom-amd64.deb

apt upgrade -y
```
