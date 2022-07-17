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
    calibre `
    ccleaner `
    cheat-engine `
    cowsay `
    cpu-z `
    crystaldiskinfo `
    ddu `
    delta `
    deno `
    dig `
    dog `
    dotnet-sdk `
    draw.io `
    flac `
    foobar2000 `
    gcc `
    git `
    go `
    gpg4win `
    gpu-z `
    gradle `
    groovy `
    handbrake `
    hwinfo `
    iperf3 `
    jq `
    keepassxc `
    less `
    lsd `
    ln `
    madvr `
    micronaut `
    msiafterburner `
    msikombustor `
    nmap-portable `
    nodejs-lts `
    obsidian `
    oh-my-posh3 `
    openssl `
    picard `
    pnpm `
    posh-docker `
    post-git `
    postgresql `
    postman `
    potplayer `
    prime95 `
    pwsh `
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
    sudo `
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
    zulu8 `
    zulu11 `
    zulu17-sdk `
    zulu

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
