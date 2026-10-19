# VPC

**Big picture:** a VPC is an address space you define in an AWS account. A subnet is one link inside that space. The instance is a machine on that link. The public address is a rewrite at the edge.

Related: [The network](network.md) · [NAT](nat.md) · [CIDR](cidr.md) · [AWS inventory](../AWS/vpc.md)

??? note "Terms"

    VPC
    : A private address space in one AWS account, in one region. On the drawing it is `10.0.0.0/16`. You choose that prefix when you create the VPC. AWS stores it.

    Subnet
    : One block inside that space, and one link. On the drawing, the instance's table has `10.0.1.0/24`. The VPC router's table has the whole `10.0.0.0/16`.

    ENI
    : The instance's interface. The address belongs to it. A security group is the filter on that interface.

    Internet gateway
    : Attached to the VPC. It rewrites the ENI's private address to a public one. On the drawing, `10.0.1.20` becomes `198.51.100.20`.

## The drawing

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 360" role="img">
  <title>The instance ENI and the VPC router's reserved address share the subnet link</title>
  <rect x="24" y="24" width="420" height="312" rx="6" fill="#fafafa" stroke="#4527a0" stroke-width="1.5"/>
  <text x="234" y="64" text-anchor="middle" fill="#311b92" font-size="16">VPC router</text>
  <rect x="48" y="100" width="280" height="68" fill="#fff" stroke="#b39ddb"/>
  <rect x="48" y="100" width="280" height="20" fill="#ede7f6" stroke="#b39ddb"/>
  <text x="56" y="114" fill="#311b92" font-size="11" font-weight="600">Destination</text>
  <text x="188" y="114" fill="#311b92" font-size="11" font-weight="600">Where</text>
  <rect x="48" y="120" width="280" height="24" fill="#ede7f6" stroke="#b39ddb"/>
  <text x="56" y="136" fill="#311b92" font-size="12">10.0.0.0/16</text>
  <text x="188" y="136" fill="#311b92" font-size="12">local</text>
  <rect x="48" y="144" width="280" height="24" fill="#fff3e0" stroke="#b39ddb"/>
  <text x="56" y="160" fill="#e65100" font-size="12">0.0.0.0/0</text>
  <text x="188" y="160" fill="#e65100" font-size="12">internet gateway</text>
  <rect x="556" y="24" width="420" height="312" rx="6" fill="#fff" stroke="#4527a0" stroke-width="1.5"/>
  <text x="766" y="64" text-anchor="middle" fill="#311b92" font-size="16">Instance</text>
  <text x="766" y="86" text-anchor="middle" fill="#6a1b9a" font-size="13">security group</text>
  <rect x="580" y="108" width="250" height="68" fill="#fff" stroke="#b39ddb"/>
  <rect x="580" y="108" width="250" height="20" fill="#ede7f6" stroke="#b39ddb"/>
  <text x="588" y="122" fill="#311b92" font-size="11" font-weight="600">Destination</text>
  <text x="730" y="122" fill="#311b92" font-size="11" font-weight="600">Where</text>
  <rect x="580" y="128" width="250" height="24" fill="#e0f2f1" stroke="#b39ddb"/>
  <text x="588" y="144" fill="#00695c" font-size="12">10.0.1.0/24</text>
  <text x="730" y="144" fill="#00695c" font-size="12">ENI</text>
  <rect x="580" y="152" width="250" height="24" fill="#fff3e0" stroke="#b39ddb"/>
  <text x="588" y="168" fill="#e65100" font-size="12">0.0.0.0/0</text>
  <text x="730" y="168" fill="#e65100" font-size="12">10.0.1.1</text>
  <line x1="420" y1="250" x2="580" y2="250" stroke="#00695c" stroke-width="2"/>
  <text x="500" y="242" text-anchor="middle" fill="#00695c" font-size="11">subnet</text>
  <rect x="270" y="227" width="150" height="46" rx="4" fill="#fff" stroke="#00695c" stroke-width="1.5"/>
  <text x="345" y="245" text-anchor="middle" fill="#00695c" font-size="13" font-weight="600">10.0.1.1</text>
  <text x="345" y="261" text-anchor="middle" fill="#00695c" font-size="12">reserved</text>
  <rect x="580" y="227" width="140" height="46" rx="4" fill="#fff" stroke="#00695c" stroke-width="1.5"/>
  <text x="650" y="245" text-anchor="middle" fill="#00695c" font-size="13" font-weight="600">ENI</text>
  <text x="650" y="261" text-anchor="middle" fill="#00695c" font-size="12">10.0.1.20</text>
</svg>

## Where the prefix is stored

You choose `10.0.0.0/16` when you create the VPC. AWS stores that prefix on the VPC. You choose `10.0.1.0/24` when you create the subnet, and AWS stores that as a piece of the VPC prefix.

The subnet route table, which is the VPC router's table, holds `10.0.0.0/16`. The instance holds `10.0.1.0/24`, taken from the mask on its ENI, the way the laptop takes `192.168.1.0/24` from the mask on Wi-Fi. The instance's table has no row for the rest of `10.0.0.0/16`. A packet to `10.0.2.20` matches the instance's default route, and the VPC router is what still knows the whole space.

## The next hop

The instance's table:

| Destination | Where to send it |
|---|---|
| `10.0.1.0/24` | the ENI |
| `0.0.0.0/0` | `10.0.1.1` |

`10.0.1.21` matches the subnet row, so the instance delivers it on the subnet. The security group on the ENI filters what that interface accepts and sends.

The subnet route table:

| Destination | Where to send it |
|---|---|
| `10.0.0.0/16` | local |
| `0.0.0.0/0` | the internet gateway |

`10.0.2.20` matches `10.0.0.0/16`, so the VPC router forwards it and the packet stays in the VPC. `1.1.1.1` matches the default route and goes to the internet gateway.

`198.51.100.20` is a one-to-one rewrite of `10.0.1.20` at that gateway. The ENI keeps `10.0.1.20`. A private subnet points its default route at a NAT gateway instead, and that gateway does the shared rewrite from the [NAT](nat.md) page.

??? note "A container running on the instance"

    In bridge mode the packet is rewritten twice. The instance turns `172.17.0.2` into the ENI address `10.0.1.20`. The internet gateway or the NAT gateway then rewrites `10.0.1.20` to a public address.

    In `awsvpc` mode the task's `eth0` is an ENI on the subnet. Its packets use that subnet's route table.

    A network ACL is the filter on the subnet. A security group remembers the connection, so a reply to allowed outbound traffic is allowed back. A network ACL has a rule for each direction.

## Key takeaways

- The VPC is the address space. The subnet is one link inside it. The instance is a machine on that link.
- You choose the prefixes. AWS stores them. The instance stores only its subnet row.
- The ENI keeps its private address. The public address is a rewrite at the internet gateway.
- A security group filters at the ENI.

## Gotchas

- `10.0.1.1` is the address reserved on the subnet for the VPC router. It is not a name the instance gives an interface.
- The instance's table holds `10.0.1.0/24`. The VPC router holds `10.0.0.0/16`.
- The security group on the ENI filters the packet after the route matches.
