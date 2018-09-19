#!/bin/bash

apt update

apt install -y git
wget -O atom-amd64.deb "https://atom.io/download/deb"
dpkg -i atom-amd64.deb

apt upgrade -y
