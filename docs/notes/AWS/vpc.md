# VPCs and Subnets

## VPC Concepts

Virtual Private Cloud (VPC)
: A virtual network dedicated to your AWS account

Subnet
: A range of IP addresses in your VPC.

Route table
: A set of rules (called **routes**) that are used to determine where network traffic is directed.

Internet gateway
: A gateway that is attached to your VPC to enable communication between resources in your VPC and the internet

VPC endpoint
: Enables you to privately connect your VPC to supported AWS services and VPC endpoints. This is powered by one of:
    * PrivateLink without requiring an internet gateway
    * NAT device
    * VPN connection
    * AWS Direct Connect connection

CIDR block
: Classless Inter-Domain Routing. An internet protocol address allocation and route aggregation methodology.

## VPC

A VPC is logically isolated from other virtual networks in the AWS Cloud. You can launch AWS resources like EC2 instances, into your VPC.

When you create a VPC, you have to specify a range of IPv4 addresses (in the form of a CIDR block).

If you specify `10.0.0.0/16`, then your main route table will look like:

|Destination|Target|
|---|---|
|10.0.0.0/16|local|

**A VPC spans all of the Availability Zones in the Region.** 

## Subnet

Once you have a VPC, you can then specify subnets in any of the AZs. **A subnet must reside entirely in one AZ and cannot span zones.** Each subnet will also have IP addresses that is a subset of the VPC's IP addresses.

Public Subnet
: A subnet whose traffic is routed to an internet gateway.

Private Subnet
: A subnet that doesn't have a route to the internet gateway.

**If you want your instance in a public subnet to communicate with the internet over IPv4, it must have a public IPv4 address or an Elastic IP address (IPv4).**

```
//TODO Public IPv4 Addresses
```

The first 4 IP addresses and the last IP address in each subnet CIDR block is reserved. For example, for a subnet with a CIDR block `10.0.0.0/24`, the following are reserved.

|IP Address|Purpose|
|---|---|
|`10.0.0.0`|Network address|
|`10.0.0.1`|Reserved by AWS for the VPC router.|
|`10.0.0.2`|Reserved by AWS for the DNS server. The DNS server actually runs on the base of the VPC addresses plus two, but the base + 2 is also reserved for all subnets. If there are multiple CIDR blocks, the main CIDR is used.|
|`10.0.0.3`|Reserved by AWS for the future.|
|`10.0.0.255`|Network broadcast address. AWS does not support broadcast in a VPC, so this is reserved.|

> **A VPC can have multiple CIDR blocks?**
>
> Yes! You can can assign multiple CIDR blocks to a VPC. If you create a VPC with `10.0.0.0/16`, you can later add `10.2.0.0/16` to the VPC. It can then have subnets under each of these CIDR blocks. The first block is the **main CIDR block**.

### Routing

* Each subnet must be associated with a route table. 
* Each subnet is automatically associated with the main route table for the VPC.

If a subnet had the following route table:

|Destination|Target|
|---|---|
|10.0.0.0/16|local|
|0.0.0.0/0|igw-id|

All IPv4 traffic (represented by `0.0.0.0/0`) would be routed to an internet gateway (`igw-id`). (Again, it must have a public IPv4 address or an Elastic IP address). Because it'd have a public IPv4 address, it can be accessed by the internet.

If you want to prevent unsolicited inbound connections from the internet but still have outbound connections, you can use a **network address translation (NAT) gateway or instance**. Since the number of Elastic IP addresses are limited, using a NAT gateway is suggested if there a lot of instances needing public IP addresses.

```
//TODO
NAT
```

### Security

Two features are in AWS to increase security in your VPC:

1. Security groups
1. Network ACL's

Security groups control inbound and outbound traffic for your *instances*.

Network ACL's control inbound and outbound traffic for your *subnets*.

Security groups in most cases can meet your needs.

**Each subnet must be associated with a network ACL.** Every subnet created will be associated with the VPC's default network ACL.

## Default VPC

Every account comes with a **default VPC** that has a **default subnet** in each Availability Zone. 

```
\\TODO Read up on AZ
```

## Route Tables

You can associate a subnet with a particular route table.

Otherwise, the subnet is implicitly associated with the main route table. (What is the main route table?)

**Route table has a one to many relationship with subnet**

**Route table has a many to one relationship with a VPC**

## Connecting To Internet

Your default VPC includes an internet gateway.

Each default subnet is a "public" subnet. Each instance launched in these subnets has a private and public IPv4 address. These instances can communicate with the internet.

Each instance launched into a nondefault subnet has a private IPv4 address and no public IPv4 address (by default, unless you assign one). These instances can communicate with each other but not the internet.

# ENI

An elastic network interface is a logical networking component in a VPC that represents a virtual network card. It can include the following attributes:

