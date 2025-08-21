## Start a VM

* Setup a machine with Research Toolkits - https://rtoolkits.web.duke.edu/
    * Create a new project
    * Add RAPID service
        * Recommend Linux Ubuntu Server 22.04
        * Choose VM size - 2-4 cores, probably 1 per runner is a good idea

You might need to wait a bit for your VM to be created.

* Connect to VM via ssh into your VM with `ssh rapiduser@[Hostname of VM]` and with the password provided
    * Install docker - `sudo apt install docker.io`
    * Start docker - `sudo service docker start`
    * Add user account to docker group - `sudo usermod -aG docker $USER`

## Config

A couple of files will need to be edited to make things work:

* Add your machine to `inventory/servers.ini` label used doesn't really matter just needs to match the playbook (`gh-runners.yml`). Make sure you specify the user account in the `vars` entry. This will typically be `rapiduser` for rapid vms and your netid for VCM vms.

* Not a bad idea to check the setting in `gh-runners/defaults/main.yml` if you want more or less runners. Also check runner version is current.

## Add Runners

From your local machine with a copy of this repo, run:

```
ansible-playbook gh-runners.yml -b --ask-become-pass
```

You will be prompted for a GitHub action runner token and the url of your organization - get these from `https://github.com/organizations/<org>/settings/actions/runners/new?arch=x64&os=linux`.


## Clean up

Make sure to uninstall the services and then you can delete the runner folders, see `cleanup.sh` (which is hard coded)
## Cleaning up

By default this 
