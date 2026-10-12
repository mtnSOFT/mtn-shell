if [ -n "${BASH_SOURCE[0]:-}" ]; then
  MTN_SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

mtn() {
  local pull_flag=""
  local update_flag=""
  local podman_args=()

  while [ $# -gt 0 ]; do
    case "$1" in
    --pull | --pull=*)
      pull_flag="--pull=always"
      shift
      ;;
    --update)
      update_flag="1"
      shift
      ;;
    --)
      shift
      while [ $# -gt 0 ]; do
        podman_args+=("$1")
        shift
      done
      break
      ;;
    *)
      podman_args+=("$1")
      shift
      ;;
    esac
  done

  if [ -n "$update_flag" ]; then
    if [ -d "${MTN_SHELL_DIR:-}/.git" ]; then
      git -C "$MTN_SHELL_DIR" pull --ff-only || return 1
      # shellcheck source=/dev/null
      . "$MTN_SHELL_DIR/source.sh"
      echo "mtn-shell updated, run 'mtn' to start the container"
      return 0
    fi
    echo "mtn: cannot update, '${MTN_SHELL_DIR:-unknown}' is not a git checkout" >&2
    return 1
  fi

  mkdir -p ~/.mtn
  systemctl --user start podman.socket

  # Bitwarden desktop SSH agent on the host (native, flatpak, snap)
  local bw_sock=""
  local bw_args=()
  local candidate
  for candidate in \
    "${BW_SSH_AUTH_SOCK:-}" \
    ~/.bitwarden-ssh-agent.sock \
    ~/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock \
    ~/snap/bitwarden/current/.bitwarden-ssh-agent.sock; do
    if [ -n "$candidate" ] && [ -S "$candidate" ]; then
      bw_sock="$candidate"
      break
    fi
  done
  if [ -n "$bw_sock" ]; then
    bw_args=(-v "$bw_sock":/run/bw-ssh-agent.sock -e SSH_AUTH_SOCK=/run/bw-ssh-agent.sock)
  else
    echo "mtn: Bitwarden desktop SSH agent not found, ssh keys unavailable" >&2
  fi

  podman run --rm -it ${pull_flag} \
    -v /var/run/user/$(id -u)/podman/podman.sock:/var/run/user/1000/podman/podman.sock \
    -v ~/.mtn:/home/mtn-admin \
    -v /dev/bus/usb:/dev/bus/usb \
    -v ~/.config/nvim:/home/mtn-admin/.config/nvim \
    -v ~/git:/home/mtn-admin/git \
    --cap-add=NET_RAW \
    --network=host \
    --tmpfs /tmp \
    --userns=keep-id:uid=$(id -u),gid=$(id -g) \
    "${bw_args[@]}" \
    "${podman_args[@]}" \
    ghcr.io/mtnsoft/mtn-shell:latest bash --login
}
