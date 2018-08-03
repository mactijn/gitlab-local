# TODO

### DNS for `*.localhost`
This setup uses the `*.localhost` domain to function, which is a Chrome-only
feature.

Adding entries to `/etc/hosts` to make sure other tools can use this to works
well up to the point where Pages requires a wildcard domain to function.

Also, as more functionality will most likely be added in the future, more
hostnames will be used.

This is why maybe it is time to go for a proper DNS-based solution.

#### solution-related problem:
There seems to be no easy way to get the ip address for a neighbouring
container without breaching some safety barriers. This is required to
get both the DNS server IP to feed to dind, as well as to get the IP address
for the gitlab container to serve from DNS.

#### to try:
- use network=container:dind or :gitlab for DNS container
- dnsmasq
- consul
- etcd
- swarm
- derive from k8s-related solutions
- proxy
