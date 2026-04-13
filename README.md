# mtn-shell

shell in a container with tools for managing our infrastructure:

- ansible
- molecule (ansible testing)
- prettier, yamllint, ...
- kubectl, helm

## Requirements

- podman

## Setup

- copy things like required ssh keys, configs and other stuff you want to use in the container to `~/.mtn`

### Bitwarden Cli

create ~./mtn-env with the following content:
```
BW_SSH_KEY_ID="vaultwarden-id-to-your-ssh-key"
BW_ANSIBLE_VAULT_PASSWORD_ID='vaultwarden-id-to-your-ansible-password'
```

`bw login`

## Usage

`source <(curl -s https://raw.githubusercontent.com/mtnsoft/mtn-shell/refs/heads/main/source.sh)`

provides the `mtn` command. You might want to add it to your `.bashrc`.

unlock bitwarden cli with `. unlock` after entering shell by `mtn`

## Tools

### Helper Commands

**go**: does `ssh` and `sudo su -` in one single command, usage: `go my-server`
