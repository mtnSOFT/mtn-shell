# To use: source mtn.sh in your shell, then run: mtn

mtn() {
  local pull_flag=""
  local podman_args=()

  while [ $# -gt 0 ]; do
    case "$1" in
      --pull|--pull=*) pull_flag="--pull=always"; shift ;;
      --) shift; while [ $# -gt 0 ]; do podman_args+=("$1"); shift; done; break ;;
      *) podman_args+=("$1"); shift ;;
    esac
  done

  mkdir -p ~/.mtn
  systemctl --user start podman.socket

  podman run --rm -it ${pull_flag} \
    -v /var/run/user/$(id -u)/podman/podman.sock:/var/run/user/1000/podman/podman.sock \
    -v ~/.mtn:/home/mtn-admin \
    -v ~/nextcloud/titan/config/ansible_inventories/production:/home/mtn-admin/git/infra/inventories/production \
    --cap-add=NET_RAW \
    --network=host \
    --tmpfs /tmp \
    --userns=keep-id:uid=$(id -u),gid=$(id -g) \
    ghcr.io/mtnsoft/mtn-shell:latest bash --login
}
