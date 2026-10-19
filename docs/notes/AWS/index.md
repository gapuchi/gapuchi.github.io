# AWS

**Big picture:** the network comes first. Names and container services sit on it. Streams are a separate path for data that moves continuously.

## Reading order

1. [VPC](vpc.md): the AWS inventory. The address space itself is [VPC](../networking/vpc.md), under Networking.
2. [Route 53](route-53.md): DNS for those addresses.
3. [ECS](ecs.md): running containers without running the cluster yourself.
4. [EKS](eks.md): a Kubernetes control plane run by AWS.
5. [EMR on EKS](emr-on-eks.md): Spark and the rest of EMR, scheduled onto that cluster.
6. [Kinesis](kinesis-streams.md): a durable stream of records.

## Related

- [The network](../networking/network.md): interfaces, the next hop, and a container, on one drawing.
- [VPC](../networking/vpc.md): that same model as an address space in AWS.
- [CIDR](../networking/cidr.md): how a subnet's prefix is written.
- [NAT](../networking/nat.md): a NAT gateway rewrites private sources the way a home router does.
- [Kubernetes](../kubernetes/index.md): the system EKS is running.
