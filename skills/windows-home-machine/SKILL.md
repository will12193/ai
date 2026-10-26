---
name: windows-home-machine
description: "Facts and workflow for William's Windows home development machine: folder and drive layout (repos on C:, F: reserved for WSL and Docker), Git and SSH setup, shell limitations, repo clones, and the planned WSL/Docker setup. Use when: setting up or maintaining that machine, cloning repositories, working out where something lives on C: or F:, configuring WSL, Docker or development storage, or hitting 'The term 'git' is not recognized', 'Permission denied (publickey)', 'running scripts is disabled on this system' or 'Python was not found' on it."
---

# Windows home development machine

Companion to `~/.copilot/instructions/coding-agents.instructions.md`, which carries the short machine essentials (paths, shell, sync script); this file covers the setup state, Git/SSH details, gotchas and the WSL/Docker plan in depth. This is a personal, cross-repository skill: do not copy machine-specific preferences into shared repositories unless asked.

## Scope and storage

- Windows account home: `C:\Users\willc`.
- Repositories and source code: `C:\Users\willc\Documents\dev`.
- Drive `F:\`, named WSL by William, is dedicated to WSL distributions and Docker container storage.
- Keep repositories on C: unless William explicitly changes this. Explain any WSL bind-mount performance trade-offs before proposing a different location.
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
3. Get repository URLs from William. Clone into the development directory without overwriting existing folders.
4. For private HTTPS repositories use Git Credential Manager's interactive sign-in. Never ask for passwords or tokens in chat or store credentials in this skill.
5. Inspect downloaded skill files before enabling them. Do not assume arbitrary cloned folders are auto-discovered; use the supported personal skill locations.
6. Follow the active chat's workspace and confirmation requirements before modifying repositories or running project-dependent commands.
7. Verify each completed stage, then record confirmed state here, keeping planned work distinct from installed components.

## Gotchas

- `The term 'git' is not recognized` → shell started before Git's PATH entry existed → use the absolute path or restart the terminal.
- `Permission denied (publickey)` or a passphrase prompt on push/pull → `ssh-agent` has no key loaded, typically after a reboot → ask William to run `ssh-add C:\Users\willc\.ssh\id_ed25519` in his own window. Never request the passphrase in chat.
- `running scripts is disabled on this system` → `Restricted` execution policy → invoke with `-ExecutionPolicy Bypass -File`.
- `Python was not found; run without arguments to install from the Microsoft Store` → Store stub, no Python installed → do not rely on `python`; use PowerShell.

## WSL and Docker: planned, not yet configured by this setup

- Inspect Windows edition, virtualization, WSL status, and existing Docker installations before choosing installation steps.
- Confirm the Linux distribution and Docker option with William before installation.
- Use supported installation or relocation settings to place WSL distributions and Docker's persistent Linux data on F:.
- Do not assume moving a WSL distribution also moves Docker's data disk. Verify both storage locations independently.
- Keep Docker images, writable container layers, and named volumes in Docker's F:-backed storage. Bind mounts follow their host paths; repository mounts remain on C:.
- Do not format F:, unregister distributions, delete virtual disks, or move existing data without explicit confirmation and a backup plan.
- Explain elevation and restart requirements before enabling Windows features. Do not reboot automatically.
- Validate the intended distribution uses WSL 2, verify Docker can run a test container, and confirm persistent data locations before marking setup complete.

## Maintaining This Skill File

Update this file (not the instructions file, unless a fact is needed on most tasks) when machine setup state changes (installs, drive layout, WSL/Docker progress) or when you hit a Windows-specific problem whose cause and fix weren't obvious. Keep entries short: symptom, cause, fix. Move items out of the planned section only once verified.