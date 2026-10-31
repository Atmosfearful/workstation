#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")"

source ./install/apps.sh

main() {
  require_sudo

  install_base_packages

  install_1password
  install_brave
  install_zed
  install_docker
  install_devcontainer
  install_discord
  install_steam
  install_spotify

  echo
  echo "Done."
  echo
  echo "If Docker was newly installed, log out and back in before running docker without sudo."
}

main "$@"
