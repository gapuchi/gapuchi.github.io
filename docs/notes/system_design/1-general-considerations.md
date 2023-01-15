# General System Design Considerations

## Trade Offs

Choices made when designing a system always have trade-offs. Here a couple of high-level trade offs.

### Performance vs Scalability

Scalable
: Performance increases (somewhat proportionally) to the amount of resources added.

Performance
: The amount of work a system can do, or the size of work a system can handle.

`TODO: How are these traded off?`

### Latency vs Throughput

Latency
: Time to complete some unit of work.

Throughput
: Amount of work completed per unit of time.

Generally, you should aim for max throughput with acceptable latency.

### Availability vs Consistency

See CAP Theorem.

## Availability Patterns

Couple of ways to keep high availability.

> Note: Common association with availability is databases and CAP theorem, but this concept can be applied to other parts of the system - application servers, load balancers, etc.

### Failover

#### Active-Passive

Only the active server is handling traffic.

Heartbeats are sent from the active to the passive server on standby. If heartbeats are stopped/missed the passive server takes over the active's IP address and resumes the service.

Downtime is determined by how long it takes for the passive system to start. (Cold start vs pre-warmed)

Also known as master-slave failover.

#### Active-Active

Both servers are handling traffic, spreading the load between them.

If they are public facing, DNS needs to know both IP's. If it is internal, the application needs to know about both servers.

Also known as master-master failover.

#### Cons of Failover

1. More hardware and added complexity of switching to other machine or handling both.
2. Potential data loss if system fails before copied to passive.

### Replication

THIS IS DATABASE SPECIFIC. SEE Scaling in DB.