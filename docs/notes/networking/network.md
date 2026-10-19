# The network

**Big picture:** one drawing. An address belongs to an interface. Each machine owns the next hop. A container inside the laptop is another set of interfaces on that same drawing.

Related: [VPC](vpc.md) · [NAT](nat.md) · [CIDR](cidr.md) · [Namespaces](../containers/namespaces.md)

??? note "Terms"

    Interface
    : One connection point on a device. The address belongs to the interface, and the machine is the set of interfaces it has.

    Common interface names:

    | Name | What it is |
    |---|---|
    | `lo` | Loopback. The operating system creates it so the machine can talk to itself. `127.0.0.1` is the usual address. The whole block `127.0.0.0/8` means this machine, so `127.0.0.2` loops back too. |
    | `eth0` | The first Ethernet interface. `eth1` is the second. In a container, `eth0` is virtual: one end of a veth pair. |
    | `wlan0` | The Wi-Fi radio. |

    LAN and WAN
    : Which side of the router an interface faces. On the drawing, `eth0` is the LAN interface, `192.168.1.1`. `eth1` is the WAN interface, `203.0.113.10`.

    Bridge
    : A switch created in software. `eth0` plugs into it the way Wi-Fi joins a LAN. Interfaces on that switch share one subnet, and the address on the bridge itself is their gateway.

    Address
    : A number configured on an interface. IPv4 is 32 bits, written as four numbers (`192.168.1.42`).

    Subnet
    : A block of addresses whose interfaces can deliver packets to each other directly. Anything outside the block goes to a router. [CIDR](cidr.md) is how the block is written.

    Routing table
    : A list of prefixes, each with a next hop. The most specific matching prefix wins.

    Default route
    : The prefix `0.0.0.0/0`. It matches every address, and loses to any longer prefix.

    ARP
    : A question shouted on the local link: "who has this address?" The interface assigned that address answers with its hardware address. The question stays on that link.

## The drawing

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1060 660" role="img">
  <title>Interfaces sit on each machine. A small route table inside the machine lists the prefixes it knows</title>
  <rect x="16" y="40" width="660" height="370" rx="6" fill="#fafafa" stroke="#4527a0" stroke-width="1.5"/>
  <text x="520" y="84" text-anchor="middle" fill="#311b92" font-size="16">Laptop A</text>
  <rect x="36" y="108" width="270" height="210" rx="6" fill="#fff" stroke="#4527a0" stroke-width="1.5"/>
  <text x="171" y="156" text-anchor="middle" fill="#311b92" font-size="15">Container</text>
  <rect x="52" y="172" width="210" height="20" fill="#ede7f6" stroke="#b39ddb"/>
  <text x="60" y="186" fill="#311b92" font-size="11" font-weight="600">Destination</text>
  <text x="168" y="186" fill="#311b92" font-size="11" font-weight="600">Where</text>
  <rect x="52" y="192" width="210" height="24" fill="#fff" stroke="#b39ddb"/>
  <text x="60" y="208" fill="#4a148c" font-size="12">127.0.0.0/8</text>
  <text x="168" y="208" fill="#4a148c" font-size="12">lo</text>
  <rect x="52" y="216" width="210" height="24" fill="#e8f5e9" stroke="#b39ddb"/>
  <text x="60" y="232" fill="#1b5e20" font-size="12">172.17.0.0/16</text>
  <text x="168" y="232" fill="#1b5e20" font-size="12">eth0</text>
  <rect x="52" y="240" width="210" height="24" fill="#fff3e0" stroke="#b39ddb"/>
  <text x="60" y="256" fill="#e65100" font-size="12">0.0.0.0/0</text>
  <text x="168" y="256" fill="#e65100" font-size="12">172.17.0.1</text>
  <rect x="390" y="108" width="250" height="116" fill="#fff" stroke="#b39ddb"/>
  <rect x="390" y="108" width="250" height="20" fill="#ede7f6" stroke="#b39ddb"/>
  <text x="398" y="122" fill="#311b92" font-size="11" font-weight="600">Destination</text>
  <text x="530" y="122" fill="#311b92" font-size="11" font-weight="600">Where</text>
  <rect x="390" y="128" width="250" height="24" fill="#fff" stroke="#b39ddb"/>
  <text x="398" y="144" fill="#4a148c" font-size="12">127.0.0.0/8</text>
  <text x="530" y="144" fill="#4a148c" font-size="12">lo</text>
  <rect x="390" y="152" width="250" height="24" fill="#e8f5e9" stroke="#b39ddb"/>
  <text x="398" y="168" fill="#1b5e20" font-size="12">172.17.0.0/16</text>
  <text x="530" y="168" fill="#1b5e20" font-size="12">bridge</text>
  <rect x="390" y="176" width="250" height="24" fill="#e8eaf6" stroke="#b39ddb"/>
  <text x="398" y="192" fill="#3949ab" font-size="12">192.168.1.0/24</text>
  <text x="530" y="192" fill="#3949ab" font-size="12">wlan0</text>
  <rect x="390" y="200" width="250" height="24" fill="#fff3e0" stroke="#b39ddb"/>
  <text x="398" y="216" fill="#e65100" font-size="12">0.0.0.0/0</text>
  <text x="530" y="216" fill="#e65100" font-size="12">192.168.1.1</text>
  <rect x="700" y="108" width="340" height="302" rx="6" fill="#fafafa" stroke="#4527a0" stroke-width="1.5"/>
  <text x="870" y="148" text-anchor="middle" fill="#311b92" font-size="16">Router</text>
  <rect x="720" y="172" width="240" height="68" fill="#fff" stroke="#b39ddb"/>
  <rect x="720" y="172" width="240" height="20" fill="#ede7f6" stroke="#b39ddb"/>
  <text x="728" y="186" fill="#311b92" font-size="11" font-weight="600">Destination</text>
  <text x="870" y="186" fill="#311b92" font-size="11" font-weight="600">Where</text>
  <rect x="720" y="192" width="240" height="24" fill="#e8eaf6" stroke="#b39ddb"/>
  <text x="728" y="208" fill="#3949ab" font-size="12">192.168.1.0/24</text>
  <text x="870" y="208" fill="#3949ab" font-size="12">eth0</text>
  <rect x="720" y="216" width="240" height="24" fill="#fff3e0" stroke="#b39ddb"/>
  <text x="728" y="232" fill="#e65100" font-size="12">0.0.0.0/0</text>
  <text x="870" y="232" fill="#e65100" font-size="12">eth1</text>
  <polyline points="190,336 190,360 330,360" fill="none" stroke="#2e7d32" stroke-width="2"/>
  <text x="260" y="354" text-anchor="middle" fill="#1b5e20" font-size="11">veth</text>
  <polyline points="550,434 550,500 795,500 795,434" fill="none" stroke="#1565c0" stroke-width="2"/>
  <polyline points="310,532 310,500 550,500" fill="none" stroke="#1565c0" stroke-width="2"/>
  <text x="672" y="494" text-anchor="middle" fill="#0d47a1" font-size="11">Wi-Fi</text>
  <rect x="200" y="554" width="220" height="90" rx="6" fill="#fafafa" stroke="#4527a0" stroke-width="1.5"/>
  <text x="310" y="620" text-anchor="middle" fill="#311b92" font-size="16">Laptop B</text>
  <rect x="240" y="532" width="140" height="46" rx="4" fill="#fff" stroke="#1565c0" stroke-width="1.5"/>
  <text x="310" y="550" text-anchor="middle" fill="#0d47a1" font-size="13" font-weight="600">wlan0</text>
  <text x="310" y="566" text-anchor="middle" fill="#0d47a1" font-size="12">192.168.1.43</text>
  <rect x="96" y="86" width="120" height="46" rx="4" fill="#fff" stroke="#6a1b9a" stroke-width="1.5"/>
  <text x="156" y="104" text-anchor="middle" fill="#4a148c" font-size="13" font-weight="600">lo</text>
  <text x="156" y="120" text-anchor="middle" fill="#4a148c" font-size="12">127.0.0.1</text>
  <rect x="460" y="18" width="120" height="46" rx="4" fill="#fff" stroke="#6a1b9a" stroke-width="1.5"/>
  <text x="520" y="36" text-anchor="middle" fill="#4a148c" font-size="13" font-weight="600">lo</text>
  <text x="520" y="52" text-anchor="middle" fill="#4a148c" font-size="12">127.0.0.1</text>
  <rect x="70" y="296" width="120" height="46" rx="4" fill="#fff" stroke="#2e7d32" stroke-width="1.5"/>
  <text x="130" y="314" text-anchor="middle" fill="#1b5e20" font-size="13" font-weight="600">eth0</text>
  <text x="130" y="330" text-anchor="middle" fill="#1b5e20" font-size="12">172.17.0.2</text>
  <rect x="330" y="337" width="140" height="46" rx="4" fill="#fff" stroke="#2e7d32" stroke-width="1.5"/>
  <text x="400" y="355" text-anchor="middle" fill="#1b5e20" font-size="13" font-weight="600">bridge</text>
  <text x="400" y="371" text-anchor="middle" fill="#1b5e20" font-size="12">172.17.0.1</text>
  <rect x="480" y="388" width="140" height="46" rx="4" fill="#fff" stroke="#1565c0" stroke-width="1.5"/>
  <text x="550" y="406" text-anchor="middle" fill="#0d47a1" font-size="13" font-weight="600">wlan0</text>
  <text x="550" y="422" text-anchor="middle" fill="#0d47a1" font-size="12">192.168.1.42</text>
  <rect x="720" y="388" width="150" height="46" rx="4" fill="#fff" stroke="#1565c0" stroke-width="1.5"/>
  <text x="795" y="406" text-anchor="middle" fill="#0d47a1" font-size="13" font-weight="600">eth0 · LAN</text>
  <text x="795" y="422" text-anchor="middle" fill="#0d47a1" font-size="12">192.168.1.1</text>
  <rect x="880" y="388" width="150" height="46" rx="4" fill="#fff" stroke="#ef6c00" stroke-width="1.5"/>
  <text x="955" y="406" text-anchor="middle" fill="#e65100" font-size="13" font-weight="600">eth1 · WAN</text>
  <text x="955" y="422" text-anchor="middle" fill="#e65100" font-size="12">203.0.113.10</text>
</svg>

## Interfaces

Each machine's operating system assigns the address on its own interface. The container's `127.0.0.1` and the laptop's `127.0.0.1` are different interfaces.

`localhost` is a name for this machine, stored in `/etc/hosts`, and that file is read before DNS:

```
127.0.0.1  localhost
::1        localhost
```

`127.0.0.1` is the IPv4 address. `::1` is the IPv6 address on the same interface. Looking up `localhost` can return either. Typing `127.0.0.1` is IPv4 only.

A second interface, such as `eth1` on the laptop, gets its own address while `wlan0` stays up. Laptop B, `192.168.1.43`, is another interface on that same Wi-Fi link. Removing one interface leaves the others.

### How the Wi-Fi address arrives

`wlan0` already exists. Joining the Wi-Fi puts that radio on a link. The gateway arrives later, inside the DHCP reply.

1. **The radio joins an access point.** Access points announce themselves. After the password succeeds, `wlan0` is on that link. The address arrives in the next step.
2. **The operating system shouts out of `wlan0`.** A DHCP Discover goes to `255.255.255.255`, so every device on the link hears it. The home router is running a DHCP server, so it answers.
3. **The offer tells the laptop the gateway.** The reply includes an address (`192.168.1.42`), a mask (`/24`), and a gateway (`192.168.1.1`).
4. **The laptop's operating system writes it down.** It assigns `192.168.1.42` to `wlan0` and installs `192.168.1.1` as the default route.
5. **The first packet to the gateway learns the hardware address.** The laptop asks on the link, "who has `192.168.1.1`?" The router's `eth0` answers. That ARP reply binds the gateway IP to a machine on the Wi-Fi.

Typing the address in by hand is the same write. The gateway is part of what you type. Packets leaving `wlan0` use `192.168.1.42` as the source, and `wlan0` answers ARP for it.

??? note "The access point, the DHCP server, and the gateway"

    At home these are one box. They are three roles.

    - The **access point** is the radio the laptop associated with in step 1. Addresses begin at step 2.
    - The **DHCP server** is whoever answers the broadcast. The offer's router field (option 3) is the gateway IP. The mask is option 1. DNS servers are option 6.
    - The **gateway** is the IP in that field, on this drawing the router's `eth0`. ARP in step 5 binds that IP to hardware on the Wi-Fi.

    The Discover, the offer, the laptop's "I accept," and the server's confirmation are the whole exchange. The accept is a broadcast too, so every DHCP server on the link hears which offer was chosen.

    The shout stays on the local link. A DHCP server on another subnet hears it when some device on this link forwards those broadcasts.

    An office access point can be a separate box from the DHCP server and the gateway. The laptop uses the same broadcast, and the offer names the gateway.

## The next hop

Every machine has the table drawn inside it. To send a packet, the operating system picks the most specific row that contains the destination.

The operating system writes the loopback row itself. The bridge row appears when the bridge is created. The `wlan0` row comes from that interface's mask. The default route is the gateway from DHCP.

`127.0.0.1` matches `127.0.0.0/8`, so the packet comes straight back.

**Laptop B is on the same subnet, so the packet does not go through the router.** `192.168.1.43` matches `192.168.1.0/24`, so Laptop A delivers it on the Wi-Fi. Laptop A asks, on that link, "who has `192.168.1.43`?" Laptop B's `wlan0` answers.

`1.1.1.1` matches only `0.0.0.0/0`. The laptop ARPs for `192.168.1.1` and hands the packet to the router's `eth0`. The destination inside the packet is still `1.1.1.1`. The router's default route points out `eth1`. [NAT](nat.md) rewrites the source from `192.168.1.42` to `203.0.113.10` and remembers the swap. The reply is addressed to `203.0.113.10`, and NAT writes `192.168.1.42` back on the way in.

## The container

A container is a [network namespace](../containers/namespaces.md): its own interfaces, its own route table, and its own loopback.

The veth line is a cable with two ends. One end is the container's `eth0`. The other end is plugged into the bridge. A frame from one interface on the bridge to another is delivered there. The laptop routes when the packet is for `172.17.0.1`, or for a destination past the bridge.

**Another container on the same bridge does not go through the host.** `172.17.0.3` matches `172.17.0.0/16`, so the packet stays on the bridge.

A packet to `1.1.1.1` matches the container's default route. The laptop NATs the source from `172.17.0.2` to `192.168.1.42` and sends it on toward the home router, which rewrites it again. A published port is a port forward on the laptop: traffic to `192.168.1.42:8080` belongs to `172.17.0.2:80`.

## Key takeaways

- An address belongs to one interface. Each machine assigns its own.
- The most specific row in that machine's table wins.
- Same link: deliver there. Everything else goes to the gateway on that table.
- A public address is a rewrite at `eth1`. `wlan0` keeps `192.168.1.42`.

## Gotchas

- Joining the Wi-Fi comes first. The address arrives in the DHCP reply.
- The container's `127.0.0.1` and the laptop's `127.0.0.1` are different interfaces.
- `localhost` is a name in `/etc/hosts`, read before DNS.
- DNS turns a name into an address. The route table runs once the address is known.
- ARP finishes delivery on the local link.
