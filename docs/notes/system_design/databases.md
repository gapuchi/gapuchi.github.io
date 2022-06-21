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

#### Federation/ Funcitonal Parititoning

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