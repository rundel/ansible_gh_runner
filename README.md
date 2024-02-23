Example usage

```
ansible-playbook gh-runners.yml -b --ask-become-pass
```

You will be prompted for a GitHub action runner token and the url of your organization - get from `https://github.com/organizations/<org>/settings/actions/runners/new?arch=x64&os=linux`.
