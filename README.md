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

# SSH setup
SSH is set up to listen on 127.0.0.1:2222 on the host by default, so we don't
collide with any other SSH daemon. This does however not reflect properly in
the SSH-based repository links.

To overcome this problem, add the following configuration to your `~/.ssh/config` file
```
Host gitlab.localhost
  Hostname 127.0.0.1
  Port 2222
  User git
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```
