# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains an Ansible playbook for deploying and managing multiple GitHub Actions self-hosted runners on remote VMs (primarily Duke's Research Toolkit VMs). The automation handles installing Docker if needed, downloading the GitHub Actions runner, configuring multiple runner instances per host, and installing them as systemd services.

## Key Commands

### Deploy Runners
```bash
ansible-playbook gh-runners.yml -b --ask-become-pass
```

This will prompt for:
- Course name (used to organize runner directories)
- GitHub runner token (from `https://github.com/organizations/<org>/settings/actions/runners/new?arch=x64&os=linux`)
- Organization URL
- Number of runners (default: 4)

### Remove Runners
```bash
ansible-playbook runner_remove.yml -e target_hosts=sta199 -b --ask-become-pass
```

This will prompt for:
- Parent folder containing the `runner*` directories (e.g. `~/sta199`)
- Removal token from `https://github.com/organizations/<org>/settings/actions/runners` (the "Remove" dialog on any runner) — leave blank to skip deregistration

Behavior depending on whether the token is provided:
- Token provided: runs `./config.sh remove --token <token>` in each runner folder, which deregisters the runner from the GitHub org and cleans up local config/services
- Token blank: runs `./svc.sh uninstall` in each runner folder for local-only cleanup (the runners will remain listed as offline in the org until removed manually)

In both cases the parent folder is then recursively deleted. The `target_hosts` extra-var selects which inventory group to operate on (required, since `vars_prompt` runs after `hosts:` is evaluated).

### Clean Up Runners (legacy)
The [cleanup.sh](cleanup.sh) script uninstalls runner services and removes runner directories. Note: This is currently hardcoded for 4 runners (runner0-runner3). Prefer `runner_remove.yml` for new work.

## Architecture

### Playbook Structure
- [gh-runners.yml](gh-runners.yml) - Self-contained playbook with host targeting, variable prompts, default vars, and all tasks for setting up runners
- [runner_remove.yml](runner_remove.yml) - Self-contained playbook to uninstall runner services and remove the parent runner folder on a target host

### Inventory
- [servers.ini](servers.ini) - Host definitions organized by groups (e.g., `sta199`, `cr173`, `mon`, `mine`)
- Each group has a `vars` section defining `ansible_user` for SSH connections and optionally `runner_base_dir`

### Runner Deployment Flow
1. Determines current user on remote host
2. Installs Docker from official repositories if not already present (supports Debian and Red Hat based systems)
3. Starts Docker service and adds user to docker group
4. Downloads GitHub Actions runner tarball to `/tmp/`
5. Creates `{{ runner_base_dir }}/{{ course }}/runner{{ N }}` directories for each runner (N = 0 to runner_n-1)
6. Extracts runner binaries into each directory
7. Configures each runner with unique hostname-based names (`hostname-runnerN`)
8. Installs and starts systemd services for each runner

### Configuration Variables
Defined in the `vars` block of [gh-runners.yml](gh-runners.yml):
- `runner_version`: GitHub Actions runner version. Not declared by default; the playbook queries `https://api.github.com/repos/actions/runner/releases/latest` (delegated to the controller) and sets it to the latest release tag. Pin a specific version by passing `-e runner_version=2.331.0` or by adding `runner_version: "2.331.0"` to the `vars` block.
- `runner_file` and `runner_url`: Constructed from `runner_version` for downloading
- `runner_base_dir`: Base directory for runner installation (default: `~`, can be overridden per host group in `servers.ini`)

Prompted at runtime (defined in [gh-runners.yml](gh-runners.yml)):
- `course`: Course name for organizing runner directories
- `runner_token`: GitHub Actions runner registration token
- `org_url`: GitHub organization URL
- `runner_n`: Number of runners per host (default: 4)

### Target Hosts
[gh-runners.yml](gh-runners.yml) hardcodes `hosts: sta199` (see line 2) — edit this to target different host groups defined in [servers.ini](servers.ini). [runner_remove.yml](runner_remove.yml) instead reads the target group from the `target_hosts` extra-var (`-e target_hosts=...`).

## Important Notes

- Runner instances are named using the pattern `<hostname>-runner<N>` where N is the runner index
- Each runner runs as a separate systemd service
- Docker is installed automatically from official Docker repositories if not already present
