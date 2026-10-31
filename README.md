# workstation

Bootstrap an Ubuntu-compatible workstation (APT, systemd and amd64 required). Install Git first; network access and sudo are required.

```bash
git clone https://github.com/Atmosfearful/workstation.git
cd workstation
bash bootstrap.sh
```

Installs 1Password, Brave, Zed, Docker, Dev Container CLI, Discord, Steam, Spotify and base utilities. It adds third-party repositories and runs upstream installers; review the scripts before running them. Preview with `DRY_RUN=1 bash bootstrap.sh`.

After setup, sign in to 1Password and configure SSH, Git identity and application preferences separately. Never commit credentials, private keys or recovery information. If `devcontainer` is not found, add `~/.devcontainers/bin` to your `PATH`.

Docker group membership grants effectively root-level privileges. Log out and back in, or run `newgrp docker`, to apply it. Lutris and Smile are available separately via Flatpak.
