# Containers

**Big picture:** a container is a process with a private view of the system. Namespaces are that view. OCI is the standard for how you pack and start it.

## Reading order

1. [Namespaces](namespaces.md): mount, UTS, IPC, PID, network, user, and cgroup. Each one hides a different resource.
2. [OCI](oci.md): the runtime spec and the image spec built on top of that isolation.

## Related

- [Linux users and groups](../linux/index.md): user namespaces remap UIDs, the same idea as ID mapping.
- [Docker privileges](../docker/privileged.md): a mode that hands the container back most of the host.
- [The network](../networking/network.md): the bridge, the veth pair, and the route tables.
- [Kubernetes](../kubernetes/index.md): scheduling these processes across a cluster.
