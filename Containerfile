FROM ubuntu:24.04

ENV HOME=/home/mtn-admin
ARG USER_ID=1000
ENV ANSIBLE_NO_LOG=false
ENV USER=mtn-admin
ENV USER_ID=${USER_ID}

# Copy helper scripts and make executable
COPY ./container/scripts /tmp/container-scripts
RUN chmod -R +x /tmp/container-scripts

# Install packages and tools via script
RUN /tmp/container-scripts/install-packages.sh

# Create user and workspace
RUN userdel -r ubuntu || true
RUN useradd -u ${USER_ID} -m -s /bin/bash mtn-admin \
  && echo "mtn-admin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && chown -R mtn-admin:mtn-admin $HOME
RUN mkdir /opt/python-venv \
  && chown mtn-admin:mtn-admin /opt/python-venv

# Configure bash prompt and aliases via script
RUN /tmp/container-scripts/setup-shell.sh
ENV PATH="/opt/python-venv/bin:$PATH"
# we're using hosts podman, so redirect the socket
ENV CONTAINER_HOST=unix:///var/run/user/1000/podman/podman.sock

COPY ./container/scripts/bin /opt/mtn-shell/bin
ENV PATH="/opt/mtn-shell/bin:$PATH"
ENV ANSIBLE_VAULT_PASSWORD_FILE="$HOME/.ansible_vault_pass.txt"

WORKDIR $HOME
USER mtn-admin

RUN /tmp/container-scripts/install-ansible.sh

HEALTHCHECK CMD [ "ls", "/" ]
