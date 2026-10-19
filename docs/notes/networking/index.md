# Networking

**Big picture:** one drawing of the home network, then a VPC as its own address space, then the rewrite at the edge, then how the prefixes are written. Names come after, because a name is only useful once an address has somewhere to go.

## Follow a packet

1. [The network](network.md): interfaces, the next hop, and a container, on one drawing.
2. [VPC](vpc.md): the same ideas as an address space in AWS. The instance is a machine on one subnet inside it.
3. [NAT](nat.md): at the public boundary the router rewrites the private source, and remembers how, so the reply can come back.
4. [CIDR](cidr.md): how the prefixes in those tables are written. Read this once `/24` and `/16` need unpacking.

## After you have an address

[DNS](dns.md) turns a name into the address the packet was following.

These two use a connection. Each stands on its own.

- [SSH](ssh.md): a tunnel and a remote shell.
- [RPC vs REST](rpc-vs-rest.md): two styles of calling another service.

## Related

- [VPC inventory](../AWS/vpc.md): gateways, route tables, and the addresses AWS reserves, after the [VPC](vpc.md) page.
- [Route 53](../AWS/route-53.md): DNS, as AWS runs it.
