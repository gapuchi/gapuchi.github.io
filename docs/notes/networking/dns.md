# DNS Concepts

Some notes for myself as I familiarize myself with networking. I used [Digital Ocean](https://www.digitalocean.com/community/tutorials/an-introduction-to-dns-terminology-components-and-concepts)'s informative article as a resource.

## Terminology

Domain Name System (DNS)
: A system that resolves human friendly names to addresses

Domain Name
: Human friendly name that is associated to a resource.

> Ex: `google.com`

IP Address
: "Network addressable location". IP addresses must be unique within its network. **IPv4** is the most common form of addresses, and is written with 4 sets of numbers, each having up to 3 digits.

> 192.198.1.10

Top Level Domain (TLD)
: The most general portion of the domain.

> Ex: `com`, `org`, `io`
>
> **ICANN** (Internet Corporation for Assigned Names and Numbers) give control to these TLD to specific parties, which then distributes domains under the TLD.

Hosts
: Computers/Services accessible through domain

>    Domain owners often expose their webserveres through their bare domain e.g. `google.com` and also through the **host definition** `www`, e.g. `www.google.com`. There can also be other host definitions, such as `api` (`api.google.com`) for API's or `files` (`files.google.com`) for ftp.

SubDomain
: A domain that is a part of a larger domain

> `google.com` is a subdomain of `com`.
>
> It looks similar to hosts, but `www.google.com` points to a resource/computer/service, and does not divide the `google.com` domain (which is what subdomains do).

Fully Qualified Domain Name
: Absolute domain name. Ends with a dot to indicate the root of the DNS heirarchy.

> `mail.google.com.`

Name Server
: A computer that translates domain names to IP addresses.

> Can be **authorative**, giving the answer to a domain they own. Else, they point to another server, serve cached, or other server's data.

Zone File
: A text file that holds the mappings between domain names and IP addresses. Stored in **name servers**, it defines resources for the subdomain (or where to go to see the definition)

Records
: A single mapping between a resource and a name residing in a zone file. This can map a domain to an IP address, define the name server for a domain, etc.

Root Servers
: The top servers of the DNS heirarchical structure. These are controlled by various organizations, delegated by ICANN. There are only a handful of these root servers, but are mirrored due to the high traffic flow to resolve names. Each mirror share the same IP address. These servers 