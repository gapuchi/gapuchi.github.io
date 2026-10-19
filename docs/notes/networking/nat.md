# NAT

**Big picture:** a private address names a machine on the LAN. NAT rewrites the packet's addresses at the WAN boundary and remembers the change, so the reply can be written back.

Related: [The network](network.md) · [VPC](vpc.md)

## Terms

Private address
: An address in `10.0.0.0/8`, `172.16.0.0/12`, or `192.168.0.0/16`. Every home can use `192.168.1.42`. Public routers have routes for the public ranges.

NAT
: Network address translation. Rewriting addresses in a packet as it crosses between a private range and a public one.

Port
: A number on a conversation, written after the address (`192.168.1.42:52341`). It lets many conversations share one address.

Translation table
: The router's memory of each rewrite. An outbound packet creates a row. A reply is translated back by looking that row up.

## Why the source changes

Laptop A sends a packet from `192.168.1.42` to `1.1.1.1`. [The network](network.md) delivers it to the router's LAN interface and out the WAN interface. Many homes use `192.168.1.42`. Public routers have a route to the WAN address, `203.0.113.10`, so the reply has to be addressed there.

The WAN interface is the boundary. Its address, `203.0.113.10`, is the one the rest of the internet can send to.

## The rewrite

The router changes the source and writes down what it did. The destination stays `1.1.1.1`.

| | Source | Destination |
|---|---|---|
| Laptop sends | `192.168.1.42:52341` | `1.1.1.1:443` |
| After NAT, on the wire | `203.0.113.10:52341` | `1.1.1.1:443` |
| Reply arrives | `1.1.1.1:443` | `203.0.113.10:52341` |
| After reversing NAT | `1.1.1.1:443` | `192.168.1.42:52341` |

The row in the translation table is `203.0.113.10:52341` belongs to `192.168.1.42:52341`. The reply matches that row, so the router puts the private address back and delivers the packet on the LAN.

Laptop B can do this at the same time. Both packets leave as `203.0.113.10`. The port is how the table tells them apart. If `52341` is already in use, the router picks another port on the way out and remembers that too. One public address stands for every laptop on the LAN.

## What arrives uninvited

A packet from the internet to `203.0.113.10` is forwarded when a row matches. The laptops are reachable for conversations they started, and for ports a forward opens.

A port forward is a row you write yourself: "traffic to `203.0.113.10:80` is for `192.168.1.42:80`." That is an inbound mapping that exists before any laptop speaks.

## Key takeaways

- NAT rewrites addresses. Routing chooses the next hop. They are separate steps at the same boundary.
- The translation table is what makes the reply find the right laptop.
- The port is part of the row, so one public address stands for every laptop.
- The public internet sees `203.0.113.10`.

## Gotchas

- NAT rewrites the packet. The laptop's interfaces stay as they are.
- Two homes can both use `192.168.1.42`. The public addresses are what must be unique.
- A service on the laptop is reachable from the internet through a port forward, or through a row an outbound connection already created.
