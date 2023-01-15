# Database

## Relational Database Management System (RDBMS)

Data is organized in tables.

ACID is a property of relational databases

- Atomicity - Each transaction is all or nothing
- Consistency - Any transaction will bring the database from one valid state to another
- Isolation - Executing transactions concurrently has the same results as if the transactions were executed serially
- Durability - Once a transaction has been committed, it will remain so

### Scaling 

- Master - slave replication. Master reads and writes, slaves reads. Slaves can also replicate to other slaves. If master is down, we can't write, just read.

    - We need logic if we want to promote a slave to a master.

- Master - master replication. Both read and write and coordinate with each other.

    - We need a LB or logic in choosing which master to invoke.
    - Most are loosely consistent (to sync with each other) which breaks ACID or have higher latency.
    - We need conflict resolution as more masters are added.

General downsides

- Loss of data if master dies before replicating
- High volume of writes will add load to slaves
- More slaves, more replication, causing lag.

#### Federation/ Functional Parititoning

Split databases into logic groups. One db for customers, one for orders, etc.

This results in less traffic to each one and less replicaiton lag.

Downsides
- Joining is complex
- App logic to determine which DB to choose
- Not effective schema requires large functions or tables.

#### Sharding

Splits data across multiple DBs.

Less traffic, less replicaiton lag, smaller indices.

Downsides

- Distribution is lopsided, power users can cause load on one shard.
- Joining across shards is complex.
- Rebalancing add complexity

### Denormalization

Tried to improve reads at the expense of writes by duplicating data across tables.

## NoSQL

Most do not have ACID properties because they are eventually consistent

They tend to have BASE properties

- Basically available - the system guarantees availability.
- Soft state - the state of the system may change over time, even without input.
- Eventual consistency - the system will become consistent over a period of time, given that the system doesn't receive input during that period.

## Consistency Patterns

With duplication of data across nodes, we need to consider how we synchronize them.

> See CAP Theorem for Consistency definition.

### Weak Consistency

After a write, a read may or may not see it, best effort.

> Example - Video Calls. You may lose reception and for that time video is frozen, you'll not get the data.

### Eventual Consistency

After a write, a read will eventually see it (usually within milliseconds). Data is replicated asynchronously.

This is seen in DNS and email. Works well in highly available systems.

### Stong Consistency

After a write, reads will see it. Data is replicated synchronously.

This is seen in file systems and RDBMS's. Works well in systems that needs transactions.

## CAP Theorem

Consistency, Availability, Parition Tolerant

Consistency
: All nodes in a distributed system sees the same state or data at the same point in time. Every read receives the most recent write or an error

Availability
: Resistance to failure. If some nodes are down, other nodes would be able to keep the system running. Every request to an active node receives a (non-error) response, without the guarantee that it contains the most recent write.

Partition Tolerant
: The system continues to operate despite an arbitrary number of messages being dropped (or delayed) by the **network** between nodes.

**It is impossible for a distributed system to provide more than two of these properties**

> CAP is frequently misunderstood as if one has to choose to abandon one of the three guarantees at all times. In fact, the choice is really between consistency and availability only when a network partition or failure happens; at all other times, no trade-off has to be made.

|System|C|A|P|
|---|---|---|---|
|noSQL|N|Y|Y|
|RDBMD|Y|Y|N|

noSQL is **not consistent**, rather it has **eventual consistency**. Changes are not applied to every component in this distributed system at the same time. Hence "eventual".

Relational DB's do not support distributed joins out of the box - it is very difficult to implement, so it does not support partitioning of data.

Choose a system that meets the use cases' requirements.

> Example - An Ordering System (like Ebay)
>
> Consistency is important in this system. Otherwise an item may be over ordered. So we would go with relational.

> Ex: Twitter
>
> Twitter gave up consistency for high scalability with paritioning.

|CAP Type|Example|
|---|---|
|CA|A single node server. In the presence of the network partition, a distributed system is either available or consistent.|
|CP|If a network between two nodes break, it will refuse to respond to a request, so availability is gone.|
|AP|If a network between two nodes break, it will still process request, but not all nodes have the same data. So consistency is gone.|