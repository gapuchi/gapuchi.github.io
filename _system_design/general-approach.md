---
layout: notes
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