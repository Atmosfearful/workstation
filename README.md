# workstation

Bootstrap an Ubuntu-compatible workstation (APT, systemd and amd64 required). Install Git first; network access and sudo are required.

```bash
git clone https://github.com/Atmosfearful/workstation.git
cd workstation
bash bootstrap.sh
```

## Installed software

- 1Password desktop app
- Tailscale
- Brave browser
- Zed editor
- Docker Engine and CLI, containerd, Docker Buildx and Compose plugins
- Dev Container CLI
- Discord
- Steam
- Spotify
- Base packages: `ca-certificates`, `curl`, `debsig-verify`, `gpg`, and `micro`

The script adds third-party repositories and runs upstream installers; review it before running. Preview with `DRY_RUN=1 bash bootstrap.sh`. Package dependencies may install additional software.

## Post-install

- Sign in to 1Password and configure SSH and Git identity.
- Connect to your tailnet: `sudo tailscale up`.
- Log out and back in, or run `newgrp docker`, to apply Docker group membership. This group grants effectively root-level privileges.
- If needed, add `~/.devcontainers/bin` to your `PATH` and restore application preferences. Lutris and Smile are available separately via Flatpak.

Never commit credentials, private keys or recovery information.
