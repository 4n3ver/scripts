 # nodejs PPA
 # https://github.com/nodesource/distributions/blob/master/README.md#debinstall
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# dotnet PPA
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu#2004-
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb
sudo apt-get update && sudo apt-get install -y apt-transport-https

# awscli ssm plugin
# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
curl https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb -o session-manager-plugin.deb
sudo dpkg -i session-manager-plugin.deb && rm session-manager-plugin.deb

# upgrade existing packages
sudo apt update && sudo apt upgrade -y

# upgrade operating system to latest release
sudo do-release-upgrade

sudo apt install -y \
    bat \
    curl \
    pv \
    ncat \
    traceroute \
    git \
    awscli \
    knot-dnsutils \
    nodejs \
    dotnet-sdk-6.0 \
    openjdk-8-jdk \
    openjdk-11-jdk \
    openjdk-17-jdk \
    build-essential \
    speedtest-cli \
    net-tools \
    iperf \
    linux-headers-$(uname -r) \
    samba \
    openssh-server

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
