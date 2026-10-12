# mtn-shell

shell in a container with tools for managing our infrastructure:

- ansible
- molecule (ansible testing)
- prettier, yamllint, ...
- kubectl, helm

## Requirements

- podman

## Setup

### Install

Clone the repository and source `source.sh` from the local checkout:

```
git clone https://github.com/mtnsoft/mtn-shell.git ~/git/mtn/mtn-shell
source ~/git/mtn/mtn-shell/source.sh
```

Add the `source` line to your `.bashrc` to have the `mtn` command available in every shell.

Do **not** source the script straight from GitHub (`source <(curl ...)`): that runs whatever
is served at that moment without any chance to review it. A checkout can be inspected,
diffed and updated deliberately.

Update the checkout later with `mtn --update` (runs `git pull --ff-only` and re-sources the script).

- copy things like required ssh keys, configs and other stuff you want to use in the container to `~/.mtn`

### SSH keys (Bitwarden desktop)

SSH keys are served by the SSH agent of the [Bitwarden desktop app](https://bitwarden.com/download/) on the host,
the keys never enter the container:

1. install the Bitwarden desktop app and log in to your Vaultwarden server (self-hosted)
2. enable `Settings → SSH agent`
3. store your keys as items of type **SSH key**

`mtn` detects the agent socket of native, flatpak and snap installs and mounts it into the container.
Set `BW_SSH_AUTH_SOCK` to use a different socket path. Check with `ssh-add -l` inside the shell;
every key use has to be approved in the desktop app.

### Bitwarden Cli

The Bitwarden CLI provides the ansible vault password. Create `~/.mtn/.mtn-env` with the following content:

```
BW_ANSIBLE_VAULT_PASSWORD_ID='vaultwarden-id-to-your-ansible-password'
```

```
bw config server https://my-vaultwarden-server.example.com
bw login
```

A `.ansible_vault_pass.txt` left over from older versions in `~/.mtn` is no longer used and can be deleted.

## Usage

`mtn` starts the container shell (see [Install](#install) for how to get the command).

| Command        | Description                                            |
| -------------- | ------------------------------------------------------ |
| `mtn`          | start the shell                                        |
| `mtn --pull`   | pull the latest container image before starting        |
| `mtn --update` | update the mtn-shell checkout and re-source the script |

Everything after `--` is passed to `podman run`.

unlock the bitwarden cli with `. bw-login` after entering the shell by `mtn`; ansible then reads the vault password from Bitwarden on demand

## Tools

### Helper Commands

**go**: does `ssh` and `sudo su -` in one single command, usage: `go my-server`
