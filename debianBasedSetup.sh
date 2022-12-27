# nodejs PPA
# https://github.com/nodesource/distributions/blob/master/README.md#debinstall
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# openrazer for Ubuntu 22.04
# https://software.opensuse.org/download.html?project=hardware%3Arazer&package=openrazer-meta
echo 'deb http://download.opensuse.org/repositories/hardware:/razer/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/hardware:razer.list
curl -fsSL https://download.opensuse.org/repositories/hardware:razer/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/hardware_razer.gpg > /dev/null

# polychromatic PPA
sudo add-apt-repository ppa:polychromatic/stable

# dotnet PPA
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu#2004-
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb

# awscli ssm plugin
# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
curl https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb -o session-manager-plugin.deb
sudo dpkg -i session-manager-plugin.deb && rm session-manager-plugin.deb

# https://wslutiliti.es/wslu/install.html
sudo add-apt-repository ppa:wslutilities/wslu

# ooni probe cli
# https://ooni.org/install/cli/ubuntu-debian
sudo apt-key adv --verbose --keyserver hkp://keyserver.ubuntu.com --recv-keys 'B5A08F01796E7F521861B449372D1FF271F2DD50'
echo "deb http://deb.ooni.org/ unstable main" | sudo tee /etc/apt/sources.list.d/ooniprobe.list

# upgrade existing packages & operating system to latest release
sudo apt update && sudo apt upgrade -y && sudo apt autoremove && sudo do-release-upgrade

# Check after upgrade
# code /etc/apt/sources.list.d/

sudo apt install -y \
    awscli \
    bat \
    build-essential \
    curl \
    dotnet-sdk-6.0 \
    git \
    hwdata \
    iperf \
    knot-dnsutils \
    linux-headers-$(uname -r) \
    linux-tools-virtual \
    ncat \
    net-tools \
    nodejs \
    ooniprobe-cli \
    openjdk-17-jdk \
    openssh-server \
    openrazer-meta \
    polychromatic-cli \
    pv \
    python3 \
    pypy3 \
    samba \
    speedtest-cli \
    traceroute \
    ubuntu-wsl \
    wslu

# Usb passthrough support
# https://github.com/dorssel/usbipd-win/wiki/WSL-support
sudo update-alternatives --install /usr/local/bin/usbip usbip `ls /usr/lib/linux-tools/*/usbip | tail -n1` 20

git config --global credential.helper "/mnt/d/scoop/apps/git/current/mingw64/libexec/git-core/git-credential-manager-core.exe"

git config --global user.email "4n3ver@reborn.com"
git config --global user.name "4n3ver"

git config --global core.autocrlf false
git config --global core.editor "code --wait"
git config --global core.eol lf
git config --global core.ignorecase false
git config --global core.pager delta

git config --global delta.navigate true
git config --global delta.light false
git config --global delta.line-numbers true

git config --global interactive.diffFilter "delta --color-only"
git config --global add.interactive.useBuiltin false

git config --global color.ui true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default
git config --global pull.rebase true
git config --global fetch.prune true
git config --global init.defaultBranch main

# Setup Oh my Posh
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

# Install PNPM; https://pnpm.io/installation#using-npm
sudo npm install -g pnpm
sudo pnpm add -g pnpm

dotnet tool install fantomas-tool -g

# Symlink home
ln -s /mnt/c/Users/yoeli/.bashrc        ~/.bashrc
ln -s /mnt/c/Users/yoeli/.bash_aliases  ~/.bash_aliases
ln -s /mnt/c/Users/yoeli/.ssh           ~/.ssh
