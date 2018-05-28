# gitlab-local
This project targets to implement a local GitLab instance for demo and
tinkering purposes.

# WARNING
Many would consider this setup incomplete and insecure, as it currently
lacks any form of SSL. A future iteration will fix this, but I cannot
stress enough on how **this is NOT in any shape to use in any multi-user
scenario** other than wanting to fiddle with specific CI/CD settings
without bothering everyone in your team with a bunch of failing test
builds, or maybe just to get a closer look at GitLab as a product in
general.

If you are looking for a production-ready version of GitLab to install,
please have a look at Gitlab Omnibus.

# Makefile
The `Makefile` lists several targets:
- `run` (default target): Creates the complete stack by invoking `run.sh`
(see below).
- `stop`: Removes the docker stack, excluding the data volumes.
- `update`: Pulls newer images if available, and updates the stack.
- `irrevokable-reset`: Removes the docker stack, including the data
volumes. Also removes files generated for or by GitLab and gitlab-runner,
like SSH keys.
- `logs`: `docker-compose logs -f`

# run.sh
This script is responsible for setting up the environment. 

~~It will make itself run in a container from the public image
`mactijn/deploy-env:latest`, hosted on Docker Hub, unless you define
the environment variable `WRAPPER_CONTAINER_IMAGE`.~~

If you wish to use a different compose file, define `COMPOSE_FILE`.

# SSH setup
We publish SSH access to GitLab to 127.0.0.1:2222 by default, so we don't
collide with any other SSH daemon. This does however not reflect properly in
the SSH-based repository links.

To overcome this problem, add the following configuration to your `~/.ssh/config` file
```
Host gitlab.localhost
  Hostname 127.0.0.1
  Port 2222
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```
