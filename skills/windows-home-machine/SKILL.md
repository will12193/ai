---
name: windows-home-machine
description: "Facts and workflow for configuring and maintaining William's Windows home development environment itself: WSL (Ubuntu LTS on F:), Docker Engine, drive/storage layout, system-level toolchains in WSL (nvm, Go), Git and SSH setup, the ai hub clones, Windows shell limitations. Not for normal development inside WSL (building, testing, running or editing project code, per-project package installs, git work in a repo), which needs none of this. Use when: setting up, changing, repairing or documenting WSL, Docker, drive storage (C: vs F: vs WSL), Windows-side Git/SSH/ssh-agent, system-level tool installs on that machine, or hitting 'The term 'git' is not recognized', 'Permission denied (publickey)', 'running scripts is disabled on this system', 'Python was not found' or a wsl.exe error on it."
---

# Windows home development machine

Companion to `~/.copilot/instructions/coding-agents.instructions.md`, which carries the one always-on rule (all development happens in WSL, never directly on Windows); this file covers everything else about the machine: setup state, Git/SSH details, gotchas and the WSL/Docker setup in depth. Load it only when working on the environment itself; routine development inside WSL does not need it. This is a personal, cross-repository skill: do not copy machine-specific preferences into shared repositories unless asked.

## The rule: develop in WSL, touch Windows only to maintain the environment

- **All development activity happens inside WSL**: editing and running project code, builds, tests, package installs, git work in repos, scripts, Docker containers. Do it from a WSL shell or a VS Code window connected to WSL, in `~/dev`. Never do it directly on the Windows side (PowerShell, `C:` or `/mnt/c` paths).
- **The only exception is actively working on the environment itself**: configuring WSL or Docker, drive/storage layout, Windows Git/SSH/ssh-agent, VS Code and terminal settings, or the Windows ai hub clone (`sync.ps1`). Do that Windows-side work only as far as the environment task needs, then go back to WSL.

## Scope and storage

- Windows account home: `C:\Users\willc`.
- Drive `F:\`, named WSL by William, is dedicated to WSL distributions and Docker container storage.
- **Windows is a host, not a development machine** (William, 2026-10-27). It keeps only what it needs to host things: the WSL feature, Git, the ssh-agent, VS Code (with its extensions, including Remote-WSL and the Docker extension) and the ai hub clone, so the setup can be maintained or fixed later. Go, Node and other toolchains are installed in WSL, never as dev tools on Windows.
- **Existing repos stay on C:.** `C:\Users\willc\Documents\dev` (currently `ai`, `clutter`, `tmp`) is left as it is, including the ai hub at `C:\Users\willc\Documents\dev\ai`, which must stay there because `sync.ps1` runs on Windows and mirrors into the Windows `~/.copilot`. Nothing is migrated.
- **New projects and repos live in a new `~/dev` inside WSL**, on the Linux filesystem (not under `/mnt/c`, which is slow for builds and file watching).
- Personal skills load from `C:\Users\willc\.copilot\skills\<skill-name>\SKILL.md`, a mirror of the ai hub repo. Edit them in the repo (see `maintain-ai-hub-backup-repo`), not there.

## Shell environment (verified 2026-10-27)

- Only Windows PowerShell 5.1 is available. `bash`, `rsync`, `pwsh` and a real `python` (only the Microsoft Store stub) are not installed, so write scripts for PowerShell 5.1.
- The execution policy is `Restricted`; scripts need `powershell -NoProfile -ExecutionPolicy Bypass -File <script>`.
- Files under `~/.copilot` use CRLF line endings.

## Git

- Git for Windows is installed at `C:\Program Files\Git\cmd\git.exe`.
- Global commit author: name `Wil`, email `willcumines@gmail.com`.
- Git Credential Manager is installed (`manager` credential helper). Public HTTPS access was verified with `git ls-remote`; private HTTPS access has not been verified.
- SSH is the preferred protocol for GitHub (account `will12193`). Key: `C:\Users\willc\.ssh\id_ed25519` (ED25519, passphrase-protected, public key registered on GitHub).
- The Windows `ssh-agent` service is set to Automatic and Git uses Windows OpenSSH via global `core.sshCommand`.
- The ai hub repo is cloned at `C:\Users\willc\Documents\dev\ai` (`git@github.com:will12193/ai.git`) and is the source of truth for global skills and instructions; use its `sync.ps1 pull` / `push` (see `maintain-ai-hub-backup-repo`).

## Workflow

1. Inspect the current installation and configuration before making changes; recorded setup facts may be stale.
2. Set up and verify Git before WSL and Docker.
3. Get repository URLs from William. Clone new repos into `~/dev` in WSL (existing ones stay in `C:\Users\willc\Documents\dev`), without overwriting existing folders.
4. For private HTTPS repositories use Git Credential Manager's interactive sign-in. Never ask for passwords or tokens in chat or store credentials in this skill.
5. Inspect downloaded skill files before enabling them. Do not assume arbitrary cloned folders are auto-discovered; use the supported personal skill locations.
6. Follow the active chat's workspace and confirmation requirements before modifying repositories or running project-dependent commands.
7. Verify each completed stage, then record confirmed state here, keeping planned work distinct from installed components.

## Gotchas

- `wsl: Unknown key 'wsl2.sparseVhd' in C:\Users\willc\.wslconfig` (same for `autoMemoryReclaim`) → these keys are not valid under `[wsl2]` → put them under `[experimental]`.
- `Wsl/Service/WSL_E_DISTRO_NOT_STOPPED` / "The VHD is currently in use" from `wsl --manage` (or `vmmemWSL` still running after `wsl --shutdown`) → a VS Code window connected via Remote-WSL (or an open Ubuntu terminal) restarts the VM within seconds → ask William to close that window (not the agent chat window; do not kill VS Code), then shut down and retry. Check with `Get-CimInstance Win32_Process -Filter "Name='wsl.exe'"`.
- Ubuntu 24.04's packaged `ssh-agent.service` user unit only runs under X11 (`ConditionPathExists=/etc/X11/Xsession.options`), and `systemctl --user enable` says `The unit files have no installation config` → it exits at once and no agent socket appears → use a custom unit in `~/.config/systemd/user/` instead (details above).
- `wsl` commands (even `wsl --list` and `wsl --shutdown`) hang forever, and the first interactive `wsl -d <distro>` shows a blank window → `WslService` is wedged (seen on the first launch of a freshly installed distro, 2026-10-27); `Restart-Service` stays in `StopPending` → from an elevated prompt, `Stop-Process -Id <wslservice PID> -Force` (the service restarts cleanly), then retry. Test responsiveness from the agent shell with `Start-Job` plus `Wait-Job -Timeout` so a hang does not block the session.
- `wsl` output is UTF-16, so captured text shows spaces between letters (`T h e   W i n d o w s`) → strip NUL characters (`-replace "`0",""`) before reading it.
- Admin-only steps (enabling Windows features) cannot run from the agent's non-elevated shell → `Start-Process cmd.exe -Verb RunAs -Wait` with output redirected to a temp log; this raises a UAC prompt William must accept.
- `The term 'git' is not recognized` → shell started before Git's PATH entry existed → use the absolute path or restart the terminal.
- `Permission denied (publickey)` or a passphrase prompt on push/pull → `ssh-agent` has no key loaded, typically after a reboot → ask William to run `ssh-add C:\Users\willc\.ssh\id_ed25519` in his own window. Never request the passphrase in chat.
- `running scripts is disabled on this system` → `Restricted` execution policy → invoke with `-ExecutionPolicy Bypass -File`.
- `Python was not found; run without arguments to install from the Microsoft Store` → Store stub, no Python on Windows by design → do not install it on Windows; use PowerShell for Windows-side scripts and run Python inside WSL.

## WSL and Docker: installed and verified

Decisions (William, 2026-10-27): distribution is **Ubuntu LTS**; Docker is **Docker Engine inside WSL** (not Docker Desktop). Probed the same day: Windows 11 Pro, firmware virtualization enabled, hypervisor not yet running, `wsl.exe` and `winget` present, no `docker`, F: empty with about 233 GB free.

Done and verified (2026-10-27): WSL 3.0.3 (default version 2) and **Ubuntu 24.04 LTS** (`Ubuntu-24.04`, WSL 2, systemd enabled, default user `willc`) with the virtual disk at `F:\WSL\Ubuntu-24.04\ext4.vhdx` (installed with `wsl --install Ubuntu-24.04 --location F:\WSL\Ubuntu-24.04 --no-launch`). **Docker Engine 29.9.2** and Compose v5 are installed from Docker's official apt repo, enabled under systemd, and `willc` is in the `docker` group; `docker run hello-world` works without sudo. Docker's root dir `/var/lib/docker` is on the same F:-backed disk as `/`. `~/dev` exists in WSL.

The ext4 disk reports about 1 TB, but F: has about 233 GB, and a vhdx grows on demand, so filling it would fail on F:, not at 1 TB. Keep an eye on `F:\WSL\Ubuntu-24.04\ext4.vhdx` growth and run `docker system prune` periodically.

Also done (2026-10-27): `C:\Users\willc\.wslconfig` has `[wsl2] memory=8GB` (the machine has 32 GB; WSL's default was 16 GB; verified Ubuntu sees about 7.9 GB) and `[experimental] sparseVhd=true` and `autoMemoryReclaim=gradual`. The existing Ubuntu disk was switched to sparse with `wsl --manage Ubuntu-24.04 --set-sparse true` (the `sparseVhd` setting only applies to newly created disks), so freed space can shrink the F: vhdx. In Ubuntu, Git 2.43 has the same identity as Windows (`Wil`, `willcumines@gmail.com`), GitHub's ED25519 host key is in `~/.ssh/known_hosts` (checked against GitHub's published fingerprint `SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`), `~/.ssh/config` has a `Host github.com` block (`IdentityFile ~/.ssh/id_ed25519`, `AddKeysToAgent yes`), and a custom user unit `~/.config/systemd/user/ssh-agent.service` runs `ssh-agent` on `$XDG_RUNTIME_DIR/ssh-agent.socket` (lingering enabled, `~/.bashrc` exports `SSH_AUTH_SOCK`). The WSL key is separate from the Windows key; William generates it himself (passphrase) and adds it to GitHub.

Isolation (2026-10-27): `/etc/wsl.conf` has `[interop] appendWindowsPath=false`, so Windows `PATH` entries no longer leak into Ubuntu (verified: 0 `/mnt/` entries; `git` resolves to `/usr/bin/git`). Interop itself stays enabled and `/mnt/c` stays mounted so existing C: repos and VS Code remain reachable; do not work under `/mnt/c`. Because VS Code's folder is no longer on `PATH`, `~/.bashrc` defines a `code()` function that calls `C:\Users\willc\AppData\Local\Programs\Microsoft VS Code\bin\code` by full path, so `code .` still works. WSL's `/etc/wsl.conf` is root-owned: edit it with `sudo`, or from the agent shell with `wsl -d Ubuntu-24.04 -u root`; changes need `wsl --shutdown`.

The WSL SSH key (`~/.ssh/id_ed25519`, passphrase-protected, separate from the Windows key) is registered on GitHub and verified working by William (2026-10-27).

Terminals (2026-10-27): Ubuntu is the default profile in Windows Terminal (`defaultProfile` is the `Ubuntu-24.04` GUID in `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`) and in VS Code (`terminal.integrated.defaultProfile.windows` is `Ubuntu-24.04 (WSL)` in `%APPDATA%\Code\User\settings.json`, previously Git Bash). Inside a VS Code window connected to WSL the terminal is already Linux bash.

Node (2026-10-27): managed with **nvm 0.40.8** in WSL (`~/.nvm`, installed with the official script pinned to a tag), Node LTS (24.22.1) as the default alias, npm 11.19.1. Use `nvm install`/`nvm use` and per-project `.nvmrc` for other versions; global npm packages land under `~/.nvm`, not on Windows. Go is not installed yet: install it in WSL (official tarball under `/usr/local/go` or a version manager) when a project needs it; nvm does not manage Go.

ai hub in WSL (2026-10-27): a second clone at `~/dev/ai` (`git@github.com:will12193/ai.git`) syncs into the WSL `~/.copilot` with `sync.sh` (`rsync` and `python3` are already in Ubuntu), alongside the Windows clone and `sync.ps1`. They are independent machines as far as the hub is concerned: always `pull` before editing and `push` after, in whichever clone you edit. The Windows clone stays at `C:\Users\willc\Documents\dev\ai`.

SSH key passphrase: the WSL ssh-agent holds the key in memory only, so run `ssh-add` once in an Ubuntu terminal (William types the passphrase; never in chat) after each WSL start, i.e. after a Windows reboot or `wsl --shutdown`. Until then SSH to GitHub fails with `Permission denied (publickey)`. Agent shells that do not source `~/.bashrc` must set `SSH_AUTH_SOCK=/run/user/1000/ssh-agent.socket` themselves.

Start script (2026-10-27): `C:\Users\willc\OneDrive\Desktop\wsl-start.cmd` (double-click; a `.cmd` because the PowerShell execution policy is `Restricted`) runs `wsl.exe -d Ubuntu-24.04 --cd ~ -- bash /home/willc/.local/bin/wsl-start`. The WSL-side script `~/.local/bin/wsl-start` waits for the systemd ssh-agent socket, runs `ssh-add` only if the agent has no key (William types the passphrase), then opens VS Code on `$HOME` by full path. Two traps when changing it: `wsl.exe` strips double quotes, so `bash -ic "multi word command"` breaks (put logic in a script file instead), and files written from Windows tools into `\\wsl.localhost\...` get CRLF line endings, which bash rejects with `$'\r': command not found` (convert with `tr -d '\r'` inside WSL).

Not done yet: Go and other toolchains (install in WSL when needed).

Agent shell tip: run commands in WSL as root without a password via `wsl -d Ubuntu-24.04 -u root -- ...`. Inline quotes get mangled through PowerShell (`awk`, `tr`, `$` and `"`), so put multi-line or quote-heavy commands in a script file and run `tr -d '\r' < /mnt/c/.../script.sh | bash`.

- Inspect Windows edition, virtualization, WSL status, and existing Docker installations before choosing installation steps.
- Use supported installation or relocation settings to place the Ubuntu distribution's virtual disk on F:.
- Install Docker Engine inside Ubuntu, with its data root (`/var/lib/docker`) inside the F:-backed distribution disk. Do not assume moving a distribution also moves anything else; verify the storage location.
- Keep Docker images, writable container layers, and named volumes in the WSL filesystem. Repositories live in the WSL `dev` folder, so mounts stay on the Linux filesystem.
- Back up the distribution (`wsl --export`) before moving or changing it.
- Git and SSH inside WSL: the Windows ssh-agent is not visible from WSL. Do not copy the passphrase-protected private key across without William's confirmation.
- Do not format F:, unregister distributions, delete virtual disks, or move existing data without explicit confirmation and a backup plan.
- Explain elevation and restart requirements before enabling Windows features. Do not reboot automatically.
- Validate the intended distribution uses WSL 2, verify Docker can run a test container, and confirm persistent data locations before marking setup complete.

## Maintaining This Skill File

Update this file (not the instructions file, unless a fact is needed on most tasks) when machine setup state changes (installs, drive layout, WSL/Docker progress) or when you hit a Windows-specific problem whose cause and fix weren't obvious. Keep entries short: symptom, cause, fix. Move items out of the planned section only once verified.