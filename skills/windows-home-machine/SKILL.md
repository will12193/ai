---
name: windows-home-machine
description: "Facts and workflow for William's Windows home development machine: development happens in WSL (Ubuntu LTS on F:) with Docker Engine, nothing dev-related is installed on Windows, the dev folder is moving into WSL, plus Git and SSH setup, shell limitations and the WSL/Docker plan. Use when: setting up or maintaining that machine, installing any tool (Go, Node, Python, Docker), cloning repositories, working out where repos or storage live (C: vs F: vs WSL), configuring WSL, Docker or development storage, or hitting 'The term 'git' is not recognized', 'Permission denied (publickey)', 'running scripts is disabled on this system' or 'Python was not found' on it."
---

# Windows home development machine

Companion to `~/.copilot/instructions/coding-agents.instructions.md`, which carries the short machine essentials (paths, shell, sync script); this file covers the setup state, Git/SSH details, gotchas and the WSL/Docker plan in depth. This is a personal, cross-repository skill: do not copy machine-specific preferences into shared repositories unless asked.

## Scope and storage

- Windows account home: `C:\Users\willc`.
- Drive `F:\`, named WSL by William, is dedicated to WSL distributions and Docker container storage.
- **Development lives in WSL, not on Windows.** Go, Node and other toolchains are installed in WSL, and most things run and compile there. Do not install dev tools, runtimes or language toolchains directly on Windows; install them in WSL instead. Windows keeps only what it needs to host things (Git, VS Code, the WSL feature, the ssh-agent).
- **The whole `dev` folder is moving into the WSL filesystem** (William's decision, 2026-10-27). `C:\Users\willc\Documents\dev` is the current/legacy location until the move is done and recorded here. Inside WSL the repos live on the Linux filesystem (not under `/mnt/c`), which also avoids slow cross-filesystem I/O.
- The ai hub repo is the open question: `sync.ps1` runs on Windows and mirrors into the Windows `~/.copilot`, so it stays at `C:\Users\willc\Documents\dev\ai` until the sync is reworked or William decides otherwise. Ask before moving it.
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
3. Get repository URLs from William. Clone into the WSL `dev` folder once it exists (until then `C:\Users\willc\Documents\dev`), without overwriting existing folders.
4. For private HTTPS repositories use Git Credential Manager's interactive sign-in. Never ask for passwords or tokens in chat or store credentials in this skill.
5. Inspect downloaded skill files before enabling them. Do not assume arbitrary cloned folders are auto-discovered; use the supported personal skill locations.
6. Follow the active chat's workspace and confirmation requirements before modifying repositories or running project-dependent commands.
7. Verify each completed stage, then record confirmed state here, keeping planned work distinct from installed components.

## Gotchas

- `The term 'git' is not recognized` → shell started before Git's PATH entry existed → use the absolute path or restart the terminal.
- `Permission denied (publickey)` or a passphrase prompt on push/pull → `ssh-agent` has no key loaded, typically after a reboot → ask William to run `ssh-add C:\Users\willc\.ssh\id_ed25519` in his own window. Never request the passphrase in chat.
- `running scripts is disabled on this system` → `Restricted` execution policy → invoke with `-ExecutionPolicy Bypass -File`.
- `Python was not found; run without arguments to install from the Microsoft Store` → Store stub, no Python on Windows by design → do not install it on Windows; use PowerShell for Windows-side scripts and run Python inside WSL.

## WSL and Docker: planned, not yet configured by this setup

Decisions (William, 2026-10-27): distribution is **Ubuntu LTS**; Docker is **Docker Engine inside WSL** (not Docker Desktop). Probed the same day: Windows 11 Pro, firmware virtualization enabled, hypervisor not yet running, `wsl.exe` and `winget` present, no `docker`, F: empty with about 233 GB free.

- Inspect Windows edition, virtualization, WSL status, and existing Docker installations before choosing installation steps.
- Use supported installation or relocation settings to place the Ubuntu distribution's virtual disk on F:.
- Install Docker Engine inside Ubuntu, with its data root (`/var/lib/docker`) inside the F:-backed distribution disk. Do not assume moving a distribution also moves anything else; verify the storage location.
- Keep Docker images, writable container layers, and named volumes in the WSL filesystem. Repositories live in the WSL `dev` folder, so mounts stay on the Linux filesystem.
- Back up the distribution (`wsl --export`) before moving or changing it, and before moving the `dev` folder into WSL.
- Git and SSH inside WSL: the Windows ssh-agent is not visible from WSL. Do not copy the passphrase-protected private key across without William's confirmation.
- Do not format F:, unregister distributions, delete virtual disks, or move existing data without explicit confirmation and a backup plan.
- Explain elevation and restart requirements before enabling Windows features. Do not reboot automatically.
- Validate the intended distribution uses WSL 2, verify Docker can run a test container, and confirm persistent data locations before marking setup complete.

## Maintaining This Skill File

Update this file (not the instructions file, unless a fact is needed on most tasks) when machine setup state changes (installs, drive layout, WSL/Docker progress) or when you hit a Windows-specific problem whose cause and fix weren't obvious. Keep entries short: symptom, cause, fix. Move items out of the planned section only once verified.