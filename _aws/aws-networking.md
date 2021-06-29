# Networking

## VPC Concepts

* **Virtual Private Cloud (VPC)** - A virtual network dedicated to your AWS account
* **Subnet** - A range of IP addresses in your VPC.
* **Route table** - A set of rules (called **routes**) that are used to determine where network traffic is directed.
* **Internet gateway** - A gateway that is attached to your VPC to enable communication between resources in your VPC and the internet
* **VPC endpoint** - Enables you to privately connect your VPC to supported AWS services and VPC endpoints. This is powered by one of:
    * PrivateLink without requiring an internet gateway
    * NAT device
    * VPN connection
    * AWS Direct Connect connection
* **CIDR block** - Classless Inter-Domain Routing. An internet protocol address allocation and route aggregation methodlogy.

## Subnet Security

Two features are in AWS to increase security in your VPC:

1. Security groups
1. Network ACL's

Security groups control inbound and outbound traffic for your *instances*.

Network ACL's control inbound and outbound traffic for your *subnets*.

Security groups in most cases can meet your needs.

**Each subnet must be associated with a network ACL.** Every subnet created will be associated with the VPC's default network ACL.

## Default VPC

Every account comes with a **default VPC** that has a **default subnet** in each Availability Zone. (TODO Read up on AZ)

## Route Tables

You can associate a subnet with a particular route table.
s
Otherwise, the subnet is implicitly associated with the main route table. (What is the main route table?)

**Route table has a one to many relationship with subnet**
**Route table has a many to one relationship with a vpc**

## Connecting To Internet

Your default VPC includes an internet gateway.

Each default subnet is a "public" subnet. Each instance launched in these subnets has a private and public IPv4 address. These instances can communicate with the internet.

Each instance launched into a nondefault subnet has a private IPv4 address and no public IPv4 address (by default, unless you assign one). These instances can communicate with each other but not the internet.

# ENI

An elastic network interface is a logical networking component in a VPC that represents a virtual network card. It can include the following attributes:

