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

# Running it
Initial setup should take place through the commands in the Makefile. I was
not able to integrate this in the Docker stack to my liking yet, but efforts
are progressing towards an acceptable situation.

# SSH setup
SSH is set up to listen on 127.0.0.1:2222 on the host by default, so we don't
collide with any local SSH daemon. This does however not reflect properly in
the SSH-based repository links, which still assume the default port of 22.

To overcome this problem, add the following configuration to your
`~/.ssh/config` file
```
Host gitlab.localhost
  Hostname 127.0.0.1
  Port 2222
  User git
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

# Hostnames
This setup uses the `*.localhost` virtual domain, which is mostly a Google
Chrome thing. Also, because this trick does not properly work between the
different containers, this solution has some hardwired elements, like the IP
address range used for the container, and a bit of special config for the
runner, amongst other things.

Also, if you want to push/pull docker images from the registry, or otherwise
want to interact with GitLab or other components outside of Chrome, you should
add the following entry to your `hosts` file:

```
127.0.0.1 gitlab.localhost registry.localhost
```

As GitLab Pages works with subdomains by default, and hosts files do not
generally accept wildcards, this only will work from Chrome.

When enabling MatterMost, make sure to add it here as well.
