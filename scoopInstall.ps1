function Set-EnvVar {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [string]$Target = "User"
    )

    Set-Content env:\$Key $Value
    [Environment]::SetEnvironmentVariable($Key, $(Get-Content env:\$Key), $Target)
    Get-ChildItem env:\$Key
}

Set-EnvVar "SCOOP" "D:\scoop"
Set-EnvVar "DO_NOT_TRACK" "1"
Set-EnvVar "SAM_CLI_TELEMETRY" "0"
Set-EnvVar "AZURE_CORE_COLLECT_TELEMETRY" "0"
Set-EnvVar "DOTNET_CLI_TELEMETRY_OPTOUT" "true"
Set-EnvVar "RUST_BACKTRACE" "full"
Set-EnvVar "QT_BEARER_POLL_TIMEOUT" "-1"

Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://get.scoop.sh")

scoop install git

scoop bucket add extras
scoop bucket add java

scoop install `
    7zip `
    adb `
    aida64extreme `
    android-sdk `
    android-studio `
    aria2 `
    audacity `
    autohotkey `
    aws `
    bat `
    bind `
    calibre `
    ccleaner `
    cemu `
    cheat-engine `
    cowsay `
    cpu-z `
    crystaldiskinfo `
    ddu `
    delta `
    deno `
    dog `
    dotnet-sdk `
    draw.io `
    flac `
    foobar2000 `
    gcc `
    git `
    gpg4win `
    gpu-z `
    gradle `
    groovy `
    gsudo `
    handbrake `
    hwinfo `
    iperf3 `
    jq `
    keepassxc `
    languagetool-java `
    less `
    lsd `
    ln `
    madvr `
    msiafterburner `
    msikombustor `
    nmap `
    nodejs-lts `
    obsidian `
    oh-my-posh `
    openssl `
    pandoc `
    picard `
    pnpm `
    posh-docker `
    post-git `
    postgresql `
    postman `
    potplayer `
    prime95 `
    pwsh `
    pypy `
    python `
    qbittorrent `
    recuva `
    ripgrep `
    rtss `
    rustup `
    sbt `
    scala `
    scrcpy `
    sed `
    signal `
    speedtest-cli `
    spek `
    springboot `
    stack `
    subtitleedit `
    synctrayzor `
    sysinternals `
    texstudio `
    time `
    tor-browser `
    touch `
    unlocker `
    which `
    winaero-tweaker `
    windirstat `
    winmerge `
    wireshark `
    yubikey-manager-qt `
    yuzu `
    zip `
    zotero `
    zulu11-jdk `
    zulu17-jdk `
    zulu-jdk

scoop update *

git config --global credential.helper "manager-core"
git config --global credential.helperselector.selected "manager-core"

git config --global user.email "lennart.twen@gmail.com"
git config --global user.name "4n3ver"

git config --global core.fileMode false
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

cargo install evcxr_repl

dotnet tool install fantomas-tool -g

sudo New-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
    -Name "LongPathsEnabled" `
    -Value 1 `
    -PropertyType DWORD `
    -Force

sudo Add-DnsClientDohServerAddress `
    -ServerAddress 94.140.14.14 `
    -DohTemplate https://dns.adguard-dns.com/dns-query `
    -AutoUpgrade 1
sudo Add-DnsClientDohServerAddress `
    -ServerAddress 94.140.15.15 `
    -DohTemplate https://dns.adguard-dns.com/dns-query `
    -AutoUpgrade 1
sudo Add-DnsClientDohServerAddress `
    -ServerAddress 2a10:50c0::ad1:ff `
    -DohTemplate https://dns.adguard-dns.com/dns-query `
    -AutoUpgrade 1
sudo Add-DnsClientDohServerAddress `
    -ServerAddress 2a10:50c0::ad2:ff `
    -DohTemplate https://dns.adguard-dns.com/dns-query `
    -AutoUpgrade 1

sudo Add-DnsClientDohServerAddress `
    -ServerAddress 1.1.1.2 `
    -DohTemplate https://security.cloudflare-dns.com/dns-query `
    -AutoUpgrade 1
sudo Add-DnsClientDohServerAddress `
    -ServerAddress 1.0.0.2 `
    -DohTemplate https://security.cloudflare-dns.com/dns-query `
    -AutoUpgrade 1
sudo Add-DnsClientDohServerAddress `
    -ServerAddress 2606:4700:4700::1112 `
    -DohTemplate https://security.cloudflare-dns.com/dns-query `
    -AutoUpgrade 1
sudo Add-DnsClientDohServerAddress `
    -ServerAddress 2606:4700:4700::1002 `
    -DohTemplate https://security.cloudflare-dns.com/dns-query `
    -AutoUpgrade 1
