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

* Not a bad idea to check the settings in `gh-runners/defaults/main.yml` to make sure the runner version is current.

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

## Clean up

Make sure to uninstall the services and then you can delete the runner folders, see `cleanup.sh` (which is currently hardcoded for 4 runners: runner0-runner3).
