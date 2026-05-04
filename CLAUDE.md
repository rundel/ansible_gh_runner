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

### Clean Up Runners
The `cleanup.sh` script uninstalls runner services and removes runner directories. Note: This is currently hardcoded for 4 runners (runner0-runner3).

## Architecture

### Playbook Structure
- [gh-runners.yml](gh-runners.yml) - Self-contained playbook with host targeting, variable prompts, default vars, and all tasks for setting up runners

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
- `runner_version`: GitHub Actions runner version (currently 2.331.0)
- `runner_file` and `runner_url`: Constructed from version for downloading
- `runner_base_dir`: Base directory for runner installation (default: `~`, can be overridden per host group in `servers.ini`)

Prompted at runtime (defined in [gh-runners.yml](gh-runners.yml)):
- `course`: Course name for organizing runner directories
- `runner_token`: GitHub Actions runner registration token
- `org_url`: GitHub organization URL
- `runner_n`: Number of runners per host (default: 4)

### Target Hosts
The playbook currently targets the `sta199` host group (see line 2 of [gh-runners.yml](gh-runners.yml)). Change this to target different host groups defined in [servers.ini](servers.ini).

## Important Notes

- Runner instances are named using the pattern `<hostname>-runner<N>` where N is the runner index
- Each runner runs as a separate systemd service
- Docker is installed automatically from official Docker repositories if not already present
