---
part: 1
---

# Overview

The goal of system design is to have a realistic end to end solution. We can start with a simple solution at first and iterate with scalability, availability, security, etc. We **are not expected to design every single aspect**.

The general approach:

1. Read the question
1. Gather Requirements
1. Perform Calculations
1. Service API Design
1. Database Design
1. High Level Design
1. Low Level Design
1. Scalability and Other Issues

## 1 - Read the Question

Pretty self explanatory

## 2 - Gather Requirements

Narrow the scope of your design. Ask clarifying questions and jot them down for later.

> Do we have an expected number of users?

> How frequent will this be used?

## 3 - Perform Calculations

There are 3 general things we can calculate in most cases:

1. Data Storage - Take a rough estimate of the size of your data. *You can confirm with your interviewer*.
1. Scale of System - Number of daily users, number of calls, etc.
1. Expected Network Bandwidth

> Ex - Design YouTube
>
> Given these assumptions from Requirements Gathering:
>
> |Metric|Value|
> |---|---|
> |Number of users|1 billion|
> |Number of daily users|500 million|
> |Avg Views/User|5|
> |Number of videos uploaded|1/300 of the number of views|
> |Avg Video Size|100 MB|
> |Video Upload Bandwidth|10 MB/min|
>
> The calculations would look like:
>
> |Metric|Value|
> |---|---|
> |Views/Sec|500M Users/Day * 5 Views/User / 86400 Sec/Day = 29K Videos/Sec|
> |Videos Uploaded/Sec| 29K Videos/Sec / 300|
> |Storage|97 Videos/sec * 100MB/Video = 9700 MB/Sec|
> |Bandwidth/Sec|0.17 * 97 - 16.49 MB/Sec|

## 4 - Service API Design

We can use REST API to design basic requests we think our use cases needs. 

## 5 - Database Design

Choose relational or noSQL based on use case. You can mention to the interview that we can handle scalability iteratively, and we can revisit the decision you made here.

You do not need to spend 20 minutes on this going into every detail. Just show the main columns (like the primary key).

## 6 - High Level Design

Give a high level picture of the overall system architecture and its components, explaining what each component accomplishes.

![Image of High Level Design](/assets/img/high-level-design.jpg)

## 7 - Low Level Design

Go into futher details for some of the components. The components you further into detail depend on the question. You can ask your interviewer on what specifics you should go into.

> Should I explain XX more?

## 8 - Scalability Other Issues

Talk about scaling and its solutions (partitioning, caching, load balancing, etc). Discuss bottlenecks - call out flaws.

# Case Study - URL Shortening Service

## Gather Requirements

Functional Requirements

1. Given a URL, our service should provide a shorter, unique URL.
1. When users access this shorter URL, it should redirect to their original URL
1. The URL will expire after a certain default time. Users can provide their own expiration date if needed.

Non Functional Requirements

1. System should be highly available
1. URL redirection should happen with minimal latency

## Perform Calculations

Assumptions:

|Metric|Value|
|---|---|
|New Shortenings per month|1 million|
|Size of Object|500 bytes|
|Avg Read of Object|100 times|
|Avg Lifetime|1 year|

Calculations:

Writes - 1 million/month = ~0.38 writes/sec
Reads - 100 million/month = ~38 reads/sec
Storage - 1 million objects/month * 12 months/year * 1 year * 500 bytes/object = 6 GB

Bandwidth Write - 0.38 writes/sec * 500 bytes/write = 190 bytes/sec
Bandwidth Read - 38 reads/sec * 500 bytes/read = 19 Kb/sec

## Service API

```
createURL(url, expiration)
```

```
deleteURL(url)
```

## Database Design

This is a read intensive operation.

We can create a DB for the URLs.

|PK|Hash|
|---|---|
||Original URL|
||Creation Date|
||Expiration Date|

noSQL or SQL? There isn't any relational data, so we can use noSQL.

## High Level Design

We have the web client -> application server -> DB

## Low Level Design

A closer look at our application server. How do we create the shortened url?

#### Option 1 - Encoding a Hash

We can use a hash and then encode the bits to be diplayed.

We can encode the bits in base36 (a-z, 0-9), base 62 (a-z, A-Z, 0-9) or add "+", "/" to make it base64

We need to decide how long the URL shortening should be? 6? 8? 10?

With 6 letters, we have 64^6 = 68.7B possible values. This meets our expected sizing.

Let's say we use MD5 hash - this produces 128 bits. After encoding we get more than 21 characters (base64 encodes 6 bits). We can take the first 6 characters. If there are conflicts we can take the next letter or something.

Problems:

1. If two users enter the same URL, it will produce the same URL shortened
1. URL Encoded and Not URL encoded of the same URL will produce different shortened URLs.

##### Option 2 - Generate Keys Offline

We have a key generation service that generates random 6 letteer strings and stores them in a DB. When we create a new one, we just pull from this DB.

**Concurrency Problems?** What if two servers are pulling at the same time? We can introduce locking on the items.

How do we ensure that the key is marked as use as soon as it is provided? We can have to tables, one for not used, one for used. It can be moved to use and then providied the app server.

What is the key db size? If it is storing base64 encoding, we can provide 68.7B 6 letter keys. If each letter is one byte, then 68.7B strings * 6 letters/string * 1 byte/letter = 412GB.

How do we ensure high availability? We can have replicas of KGS.