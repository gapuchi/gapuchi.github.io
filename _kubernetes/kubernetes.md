---
layout: post
part: 1
---

# Kubernetes

Kubernetes is open source container management platform.

It

* help you run containers at scale
* provide objects and APIs for building applications

## Nodes

**Nodes** are the machines that make up a Kubernetes cluster. These can be physical or virtual.

Two types of nodes:

1. Control-plane (which makes up the Control Plane) is the brains of the cluster
1. Worker-node (which makes up the Data Plane) runs the actual container images (via pods)

## Objects

**Kubernetes objects** are entities that are used to represent the state of the cluster.

The cluster does its best to ensure it exists as defined (by the object). This is the cluster's *desired state*. The object is a *record intent*.

Kubernetes is always working to make an object's *current state* equal to the object's *desired state*.

The desired state could describe:

* What pods (containers) are running, and on which nodes
* IP endpoints that map to a logical group of containers
* How many replicas of a container are running
* Other stuff

A [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/) is a thin wrapper around one or more containers

A [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) implements a single instance of a pod on a worker node

A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) details how to roll out (or roll back) across versions of your application

A [ReplicaSet](https://www.eksworkshop.com/010_introduction/basics/concepts_objects_details_2/#replicasethttpskubernetesiodocsconceptsworkloadscontrollersreplicaset) ensures a defined number of pods are always running

A [Job](https://www.eksworkshop.com/010_introduction/basics/concepts_objects_details_2/#jobhttpskubernetesiodocsconceptsworkloadscontrollersjobs-run-to-completion) ensures a pod properly runs to completion

A [Service](https://www.eksworkshop.com/010_introduction/basics/concepts_objects_details_2/#servicehttpskubernetesiodocsconceptsservices-networkingservice) maps a fixed IP address to a logical group of pods

A [Label](https://www.eksworkshop.com/010_introduction/basics/concepts_objects_details_2/#labelhttpskubernetesiodocsconceptsoverviewworking-with-objectslabels) key/value pairs used for association and filtering

## Architecture

![Image of Kubernetes Architecture](/assets/img/kubernetes-arch.png)

### Control Plane

![Image of Control Plane Architecture](/assets/img/control-plane.png)

* One or More API Servers: Entry point for REST / kubectl
* etcd: Distributed key/value store
* Controller-manager: Always evaluating current vs desired state
* Scheduler: Schedules pods to worker nodes

### Data Plane

![Image of Data Plane Architecture](/assets/img/data-plane.png)

* Made up of worker nodes
* kubelet: Acts as a conduit between the API server and the node
* kube-proxy: Manages IP translation and routing

# Helm

**Helm** is a package manager for kubernetes. It packages multiple kubernetes resources into a single logical deployment unit called a **Chart**.

# Health Checks

https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

**Liveliness probes** are used in K8s to know when a prod is alive or dead. K8s will kill and recreate the pod when a liveliness probe doesn't pass

**Readiness probes** are used in K8s to know when a pod is ready to serve traffic. If a readiness probe fails, traffic will not be sent to the pod.

# Auto Scaling

Two forms of auto scaling:

1. **Horizontal Pod Autoscaler (HPA)** - scales the pods in a deployment or replica set. It is implemented as a K8s API resource and a controller. 
  - The controller manager queries the resource utilization against the metrics specified in each HorizontalPodAutoscaler definition.
  - It obtains the metrics from either the resource metrics API (for per-pod resource metrics), or the custom metrics API (for all other metrics).
1. **Cluster Autoscaler (CA)** - component that automatically adjusts the size of a Kubernetes Cluster so that all pods have a place to run and there are no unneeded nodes.

# Role-based Access Control (RBAC)

**RBAC** is a method of regulating access to computer or network resources based on the roles of individual users within an enterprise.

The logical components:

* **Entity** - A group/user/service account. The identity representating the application that wants to execute certain operations (actions) and requires permission to do so.
* **Resource** - A pod/service/secret that the entity wants to access using the certain operations.
* **Role** - Used to define therules for the actions the entity can take on various resources.
* **Role binding** - Attaches a role to an entity. This dictates the set of actions permitted by the entity on the specified resources. Two types roles/role bindings:
    1. Role/RoleBinding - authorization in a namespace
    1. ClusterRole/ClusterRoleBinding- authorization cluster-wide
* **Namespace** - They provide a unique scope for object names. They are intended to be used in multi-tenant environments to create virutal kubernetes clusters on the same physical cluster.

# Amazon EC2 Security Groups + Kubernetes pods

We can use Security Groups to define inbound and outbound network traffic to and from pods.

# Kubernetes Service

> Let's say we have nginx running cluster wide. We can talk to these pods directly theoretically, but what happens if a node dies? The pods die, but the deployment will create new ones, *with different IPs*. How do we get this new IP?

This is where kubernetes service comes in.

A Kubernetes service is an abstraction that defines logical set of pods running somewhere in your cluster.

When created, each Service is assined a unique IP address (aka **clusterIP**). This address is tied to the lifespan of the Service and will not change while the Service is alive.

Pods can be configured to talk to the Service, and that communication will be load-balanced automatically to some pods that are members of the Service.

## Accessing the Service

Two ways we can find a Service:

1. environment variables
1. DNS

### Environment Variables

When a pod runs on a node, `kubelet` adds a set of environment variables for each active Service.

> What happens if we were to run a pod first and then make it a Service? Environment variables won't be there

You'd have to kill the pods and wait for the Deployment to recreate them. At this point, the Service will already have existed and the env variables will be set.

### DNS

Kubernetes offers a DNS cluster add-on Service that automatically assigns DNS names to other Services.

## Exposing the Service

There may be a need to expose a Service onto an external IP address. Kubernetes support this in two ways: `NodePort` and `LoadBalancer`.

## Ingress

**Ingress** exposes HTTP and HTTPS routes from outside the cluster to Services within the cluster.

The routing itself is controlled by rules defined on the Ingress resource.

> Ingress doesn't expose arbitrary ports or protocols. If you want to expose services other than HTTP or HTTPS, use `NodePort` or `LoadBalancer`.

**Ingress Controller** is responsible for fulfilling the Ingress, commonly with a load balancer. It may configure your edge router or additional frontends to help handle the traffic.

> You need an ingress controller to satisfy an ingress. Just having an ingress doesn't do anything.

# Assigning Pods to Nodes

We can configure a pod to only run on specific nodes, or prefer certain nodes.

> This usually isn't necessary, the scheduler will do a reasonable job of this. There may be specific cases where you want to put a pod in a node with an SSD, or two pods together.