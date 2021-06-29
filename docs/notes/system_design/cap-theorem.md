---
layout: post
title: CAP Theorem
part: 2
---

# CAP Theorem

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