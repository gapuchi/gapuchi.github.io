# Load Balancer

LB distributes incoming requests to compute resources (e.g. application servers, dbs). LB's are good for 

* Preventing requests from going to unhealthy servers.
* Preventing overloading resources.
* Eliminating single point of failures. (Is this really because of LB or because of scaling?)

In general, good for horizontal scaling.

LBs can be implemented with hardware (which is expensive) or software.

Other benefits

* SSL termination - Encrypt server responses so that backend servers do not have to perform this expensive operations.
* Session persitence - Issue cookies and route specific cleint's request to the same instance (if the web app doesn't track session).

As always, to keep high availability, it is common to set up more than one LB either using active-passive or active-active mode.

Methods of routing:

* Random
* Least loaded
* Session/cookies
* Round robin or weighted round robin
* Layer 4
* Layer 7

## Layer 4

Layer 4 LB's look at the `transport layer` to distribute requests. This includes source and destination IP's, and ports. Not the actual content of the packet.

These LB's forward network packages to and from the upstream server, performing NAT.

`TODO: transport layer, NAT`

## Layer 7

Layer 7 LB's look at the `application layer` to distribute requests. This can include, contents of header, message, and cookies. LB's terminate network traffic, read the message, decide, and then open a connection to the selected server.

> LB can direct video traffic to servers that host vidoes while directing user billing traffic to security-hardened servers. This data is available on this layer.

While LB 7 is more flexibile, LB 4 requires less time and compute. The difference may be minimal though.
