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

After setup, sign in to 1Password, connect Tailscale with `sudo tailscale up`, and configure SSH, Git identity and application preferences separately. Never commit credentials, private keys or recovery information. If `devcontainer` is not found, add `~/.devcontainers/bin` to your `PATH`.

Docker group membership grants effectively root-level privileges. Log out and back in, or run `newgrp docker`, to apply it. Lutris and Smile are available separately via Flatpak.
