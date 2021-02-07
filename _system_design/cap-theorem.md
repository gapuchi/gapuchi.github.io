---
part: 2
---

# CAP Theorem

Consistency, Availability, Persistence

**It is impossible for a distributed system to provide more than two of these properties**

|System|C|A|P|
|---|---|---|---|
|noSQL|N|Y|Y|
|Relational|Y|Y|N|

noSQL is **not consistent**, rather it has **eventual consistency**. Changes are not applied to every component in this distributed system at the same time. Hence "eventual".

Relational DB's do not support distributed joins out of the box - it is very difficult to implement, so it does not support partitioning of data.

Choose a system that meets the use cases' requirements.

> Example - An Ordering System (like Ebay)
>
> Consistency is important in this system. Otherwise an item may be over ordered. So we would go with relational.

Consistency
: All nodes in a distributed system sees the same state or data at the same point in time.

Availability
: Resistance to failure. If some nodes are down, other nodes would be able to keep the system running.

Partitioning
: The data or work is broken into chunks and stored acros multiple machines. The allows horizontal growth, duplication of data, etc.

> Ex: Twitter
>
> Twitter gave up consistency for high scalability with paritioning.