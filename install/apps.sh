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
    bash -o pipefail -c "$*"
  fi
}

require_sudo() {
  run sudo -v
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
    micro
}

# https://support.1password.com/install-linux/ (Debian or Ubuntu, manual installation)
install_1password() {
  if apt_installed 1password; then
    log "1Password already installed"
    return
  fi

  if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
    echo "The 1Password APT installer supports amd64 only; install it separately on this architecture." >&2
    return 1
  fi

  log "Installing 1Password"
  run_shell 'curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/1password-archive-keyring.gpg'
  run_shell 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list >/dev/null'
  run sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22 /usr/share/debsig/keyrings/AC2D62742012EA22
  run_shell 'curl -fsSL https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null'
  run_shell 'curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --yes --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg'
  run sudo apt-get update
  run sudo apt-get install -y 1password
}

install_brave() {
  # https://brave.com/linux/ (one-command installation)
  if command_exists brave-browser || apt_installed brave-browser; then
    log "Brave already installed"
    return
  fi

  log "Installing Brave"
  run_shell 'curl -fsS https://dl.brave.com/install.sh | sh'
}

install_zed() {
  # https://zed.dev/docs/linux (standard installation)
  if command_exists zed; then
    log "Zed already installed"
    return
  fi

  log "Installing Zed"
  run_shell 'curl -f https://zed.dev/install.sh | sh'
}

# https://docs.docker.com/engine/install/ubuntu/
# https://docs.docker.com/engine/install/linux-postinstall/
install_docker() {
  if apt_installed docker-ce && apt_installed docker-ce-cli && apt_installed containerd.io && \
    apt_installed docker-buildx-plugin && apt_installed docker-compose-plugin && command_exists docker; then
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
  echo "Warning: membership in the docker group grants root-level privileges."

  run sudo groupadd -f docker
  run sudo usermod -aG docker "$USER"
  run sudo systemctl enable --now docker

  echo
  echo "Docker group configured."
  echo "Run this in your shell to use Docker immediately without logging out:"
  echo
  echo "  newgrp docker"
}

install_devcontainer() {
  # https://github.com/devcontainers/cli#install-script
  if command_exists devcontainer || [[ -x "$HOME/.devcontainers/bin/devcontainer" ]]; then
    log "Dev Container CLI already installed"
    return
  fi

  log "Installing Dev Container CLI"
  run_shell 'curl -fsSL https://raw.githubusercontent.com/devcontainers/cli/main/scripts/install.sh | sh'
}

install_discord() {
  # https://support.discord.com/hc/en-us/articles/360034561191-Desktop-Installation-Guide
  if apt_installed discord; then
    log "Discord already installed"
    return
  fi

  log "Installing Discord"

  run_shell 'curl -fsSL -o /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"'
  run sudo apt-get install -y /tmp/discord.deb
  run rm -f /tmp/discord.deb
}

install_steam() {
  # https://repo.steampowered.com/steam/ (Ubuntu LTS launcher; separate APT instructions)
  if apt_installed steam-launcher || apt_installed steam; then
    log "Steam already installed"
    return
  fi

  log "Installing Steam"

  run_shell 'curl -fsSL -o /tmp/steam.deb "https://repo.steampowered.com/steam/archive/stable/steam_latest.deb"'
  run sudo apt-get install -y /tmp/steam.deb
  run rm -f /tmp/steam.deb
}

# https://www.spotify.com/us/download/linux/ (Debian / Ubuntu)
install_spotify() {
  if apt_installed spotify-client; then
    log "Spotify already installed"
    return
  fi

  log "Installing Spotify"

  run_shell 'curl -fsS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg'

  run_shell 'echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null'

  run sudo apt-get update
  run sudo apt-get install -y spotify-client
}
