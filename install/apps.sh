#!/usr/bin/env bash

DRY_RUN="${DRY_RUN:-0}"

log() {
  echo
  echo "==> $*"
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

run_shell() {
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "+ $*"
  else
    bash -c "$*"
  fi
}

require_sudo() {
  sudo -v
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

apt_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

install_base_packages() {
  log "Installing base packages"

  run sudo apt-get update
  run sudo apt-get install -y \
    ca-certificates \
    curl \
    debsig-verify \
    gpg \
    micro \
    wget
}

install_brave() {
  if command_exists brave-browser || apt_installed brave-browser; then
    log "Brave already installed"
    return
  fi

  log "Installing Brave"
  run_shell 'curl -fsS https://dl.brave.com/install.sh | sh'
}

install_zed() {
  if command_exists zed; then
    log "Zed already installed"
    return
  fi

  log "Installing Zed"
  run_shell 'curl -f https://zed.dev/install.sh | sh'
}

install_docker() {
  if apt_installed docker-ce && command_exists docker; then
    log "Docker already installed"
  else
    log "Installing Docker"

    run sudo apt-get update
    run sudo apt-get install -y ca-certificates curl

    run sudo install -m 0755 -d /etc/apt/keyrings
    run_shell 'sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc'
    run sudo chmod a+r /etc/apt/keyrings/docker.asc

    run_shell 'sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF'

    run sudo apt-get update
    run sudo apt-get install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin
  fi

  log "Configuring Docker user group"

  run sudo groupadd -f docker
  run sudo usermod -aG docker "$USER"
  run sudo systemctl enable --now docker
}

install_devpod() {
  if command_exists devpod; then
    log "DevPod already installed"
    return
  fi

  log "Installing DevPod CLI"

  run_shell 'curl -L -o /tmp/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64"'
  run sudo install -c -m 0755 /tmp/devpod /usr/local/bin/devpod
  run rm -f /tmp/devpod
}

install_discord() {
  if apt_installed discord; then
    log "Discord already installed"
    return
  fi

  log "Installing Discord"

  run_shell 'curl -L -o /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"'
  run sudo apt-get install -y /tmp/discord.deb
  run rm -f /tmp/discord.deb
}

install_steam() {
  if apt_installed steam-launcher || apt_installed steam; then
    log "Steam already installed"
    return
  fi

  log "Installing Steam"

  run_shell 'curl -L -o /tmp/steam.deb "https://repo.steampowered.com/steam/archive/stable/steam_latest.deb"'
  run sudo apt-get install -y /tmp/steam.deb
  run rm -f /tmp/steam.deb
}

install_spotify() {
  if apt_installed spotify-client; then
    log "Spotify already installed"
    return
  fi

  log "Installing Spotify"

  run_shell 'curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg'

  run_shell 'echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null'

  run sudo apt-get update
  run sudo apt-get install -y spotify-client
}
