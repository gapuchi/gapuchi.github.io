# Components

Cluster
: The collection of Kubernetes components.

Nodes
: A worker machine in a cluster that runs containerized applications.

Pods
: A component of the application workload.

Control Plane
: Manages the worker nodes and the Pods in the cluster.

When you run Kubernetes you get a cluster.

* There is at least one node in a cluster.
* Nodes host the Pods

Diagram of the cluster:

![Diagram of the Kubernetes Cluster](/img/kubernetes-cluster-diagram.png)

## Control Plane Components

The CP makes global decisions about the cluster and detecting/responding to cluster events. This includes:

* Scheduling
* Starting a new Pod when a deployment's `replicas` field is unsatisfied.

### kube-apiserver

The API server exposes Kubernetes API and is the front end for the Kubernetes CP.

The main implementation is [kube-apiserver](https://kubernetes.io/docs/reference/generated/kube-apiserver/), which is designed to scale horizontally.

### etcd

A *consistent* and *highly-available* key value store. This stores Kubernetes cluster data.

### kube-scheduler

A component that watches for newly created Pods with no assigned node and selects a node for them to run on.

```
// TODO Look into scheduling strategies
```

### kube-controller-manager

A component that runs controller processes.

Control loop
: Watches the shared state of the cluster through the apiserver. It makes changes to attempt to get the current state to match the desired state.

|Controller Type|Description|
|---|---|
|Node controller|Monitor and respond to when nodes go down.|
|Job controller|Monitor for Job objects that represent one-off tasks and creates Pods to run those tasks|
|Endpoint controller|Populates the Endpoint object (joins Services and Pods)|
|Service Account & Token controllers|Create default accounts and API access tokens for new namespaces.|

```
// TODO Link various terminology, like Services, Pods, Job, etc.
```

### cloud-controller-manager

A component that embeds cloud-specific control logic.

This enables you to link your cluster to your cloud provider's API and separate the components that interact with your cloud platform from those that just needs your cluster.

This may not be needed if you're running the cluster on your own machine.

Some possible controllers:

|Controller Type|Description|
|---|----|
|Node controller|Checks the cloud provider to determine if a node has been deleted after it stops responding.|
|Route controller|Setting up routes in the cloud infrastructure.|
|Service controller|Creating, updating, deleting cloud provider load balancers.|

## Node Components

These are the components that run on every node.

### kubelet

An agent that ensures containers are running in a Pod.

It takes in a set of PodSpecs and sees those containers defined in them are running and healthy.

It does not manage any containers not created by Kubernetes.

### kube-proxy

A network proxy. It maintains network rules on nodes.

This allows network communication to your Pods from network sessions inside or outside of your cluster.

It implements part of the Kubernetes Service concept.

```
// TODO Services Networking
```

### Container Runtime

The software responsible for running containers.

* Docker
* containerd
* CRI-O
* any implementation of the [Kubernetes CRI](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-node/container-runtime-interface.md)

### Addons

```
// TODO
```