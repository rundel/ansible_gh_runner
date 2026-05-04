## Start a VM

* Setup a machine with Research Toolkits - https://rtoolkits.web.duke.edu/
    * Create a new project
    * Add RAPID service
        * Recommend Linux Ubuntu Server 22.04
        * Choose VM size - 2-4 cores, probably 1 per runner is a good idea

You might need to wait a bit for your VM to be created.

* Connect to VM via ssh into your VM with `ssh rapiduser@[Hostname of VM]` and with the password provided

## Config

A couple of files will need to be edited to make things work:

* Add your machine to `servers.ini` — the group label used doesn't really matter, it just needs to match the `hosts` entry in the playbook (`gh-runners.yml`). Make sure you specify the `ansible_user` in the group's `vars` section. This will typically be `rapiduser` for RAPID VMs and your NetID for VCM VMs.

* By default the playbook queries the GitHub releases API for the latest runner version. To pin a specific version pass `-e runner_version=2.331.0` on the command line, or set `runner_version: "2.331.0"` in the `vars` block of `gh-runners.yml`.

## Add Runners

From your local machine with a copy of this repo, run:

```
ansible-playbook gh-runners.yml -b --ask-become-pass
```

You will be prompted for:
- Course name (used to organize runner directories)
- GitHub Actions runner token — get this from `https://github.com/organizations/<org>/settings/actions/runners/new?arch=x64&os=linux`
- Organization URL
- Number of runners (default: 4)

Docker will be installed automatically if it is not already present (supports both Debian and Red Hat based systems).

## Remove Runners

To uninstall runner services and remove the runner folders on a host, run:

```
ansible-playbook runner_remove.yml -e target_hosts=sta199 -b --ask-become-pass
```

Replace `sta199` with the inventory group you want to target. You will be prompted for:
- The parent folder containing the `runner*` directories (e.g. `~/sta199`)
- A GH runner removal token — get this from `https://github.com/organizations/<org>/settings/actions/runners` (click "Remove" on any runner to see the token). Leave blank if you only want a local cleanup and will deregister the runners from GitHub manually.

If a token is provided the playbook runs `./config.sh remove --token <token>` in each runner folder, which deregisters the runner from the org and cleans up local config and services. If left blank it falls back to `./svc.sh uninstall` for a local-only cleanup. Either way the parent folder is recursively removed afterwards.

The legacy `cleanup.sh` script does the same local-cleanup job manually but is hardcoded for 4 runners (runner0-runner3) and does not deregister from the org — prefer the playbook.
