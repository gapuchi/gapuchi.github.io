# Scalabilty

**Clones** - Having multiple machines to handle requests.
- Ideally should be stateless. So if a caller can go to different machine.
- Sessions should be stored in a centralized place, outside of the serveres.
    - A cache or DB


Scalability vs Performance

- Performance - a single call is fast
- Scalability - a call is slow under heavy load.

Latency vs Throughput

- Latency - time for an action to complete
- Throughput - number of actions per unit of time

Goal is maximal throughput at an acceptable latency. (As opposed to furthering latency even further for a worse throughput. Not really much sense to over optimizing latency).

# Consistency

- Weak consistency - a read may not pick up a write.
    - Video Games and Phone Calls. When you lose connection, you just don't get the missing data.
- Eventual consistency - Data is replicated async, so you may not get it.
- Strong consistency - Replicated sync, blocking

# Availability

## Fail-over

For servers it seems?

- Active - passing. Passive is on stand by and takes over when heartbeat is dead. There is some downtime when switching to passive. (If passive is cold, it'll take more time.)

- Active - Active. Two servers handles reads and writes.

Downsides - Additional hardware. Loss of data if master dies before replication.

## Replication

For DB it seems?


