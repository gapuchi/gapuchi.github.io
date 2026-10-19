# Kubernetes

**Big picture:** a cluster is a control plane plus worker nodes. You talk to it through the API. The scheduler is what turns a desired pod into a running one.

## Reading order

1. [Kubernetes](1-kubernetes.md): what the system is, and the objects it manages.
2. [Components](2-components.md): control plane and worker nodes, and what each process does.
3. [API](3-api.md): how those objects are stored and requested.
4. [Scheduling](4-scheduling.md): how a pod is placed, and how it gets preempted or evicted.

## Related

- [Container namespaces](../containers/namespaces.md): the kernel isolation a pod is built from.
- [EKS](../AWS/eks.md): this same control plane, run by AWS.
