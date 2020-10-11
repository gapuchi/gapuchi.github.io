# Preface

*Data Intensive Applications* - An application whose primary challenge is data: quantity, complexity, or speed at which data is changing. As opposed to *compute intensive*:

*Compute Intensive* - CPU cycles is the bottleneck.

# Foundation of Data Systems

The fundamential ideas applicable to all data systems.

## Reliable, Scalabe, and Maintainable Applications

A data intensive application is usually built from standard building blocks that provide functionality common across many data intensive applications:

### Thinking About Data Systems

A data system is a conglomeration of various tools, rather than a single tool. Base functionality common across data systems:

* Store data (databases)
* Remember expensive operations (cache)
* Search data (search indices)
* Send message to another process (stream processing)
* Periodically crunch chunks of data (batch processing)

Because of the varied need of data systems, it is hard, if not impossible, to have a single tool to meet all the requirements. This means that developers have to choose and combine various tools and *design a data system*, rather than solely developing an application.

> For example, a system can include stream processing, a database that needs high writes and low reads, and no indices, because of the requirements provided. A system designer would pick the appropriate database, connect it a stream processing, and have no need for a cache. The choices and possible outcomes are many.

**There are a lot of questions that can arise when thinking about data system design**. This section addresses the three important concerns:

* Reliability - The system should work *correctly* in the face of *adversity*
* Scalability - The system should be able to deal with its *growth*
* Maintainability - Various people should be able to work on the system *productively*

### Reliability

*Reliability* is basically **the ability to continue working properly, even when things go wrong**. These things that can go wrong are called *faults*, and a system that can handle *faults* are known to be *fault-tolerant* or *resilient*. (This doesn't mean a system handle handle every fault, however.)

**A *fault* is not the same as a *failure*:**

* A *fault* is typically when a component of a system stops working as expected
* A *failure* is typically when the system as a whole stops working for the user

It is best to design *fault-tolerance mechanisms* in your system to prevent *faults* causing *failures*.

In these *fault-tolerant* systems, it may be useful to **increase the number of faults** by triggering them on purpose. This ensures that the system is working as expected by testing these mechanisms.

Although **tolerating faults is preferred over preventing faults**, there are some cases where prevention is better than the cure (e.g. where there is no cure, like a security breach).

#### Hardware Faults

Hard disk crashes, faulty RAM, black outs. These happen all the time, especially when there are more and more machines:

> Lets say a hard drive has a life expectancy of 10 - 50 years before it failes. If we have a storage cluster of 10,000 disks, then we can expect 1 disk to fail everyday.

The first response to this is to **add redundancy**. When a component fails, a redundant component takes its place. Although it won't solve all hardware problems, it is a familiar tactic that can leave a machine running uninterupted for years.

> Disks has RAID, data centers have backup power generators, servers have dual power supplies and hot-swappable CPU's.

Until recently, hardware redundancy was good enough for most applications, since it makes a failure of a machine rare. If a machine went down, as long as there was a way to move a backup onto a new machine, the downtime of an application wasn't that bad.

> This meant that applications that had multi-machine redundancy were very few, only in cases where high availability was *absolutely* essential.

This is changing however. As the demands on applications have increased, they have started using more machines, which means a higher hardware failure rate in their application.

> In cloud platforms like AWS, it is very common for a machine to go down for various reasons, since cloud platform focuses on elasticity and flexibility over the reliability of a single machine.

So, there is a move toward systems that **can handle loss of an entire machines** by using **software fault-tolerance techniques** in addition to or instead of *hardware redundancy*.

An advantage of this - with a single machine you need to plan downtime if you want to upgrade, reboot, or do an interuppting maintainence on the machine. A system that can handle machine loss can be patched one node at a time, without any interruptions.

#### Software Errors

*Systematic errors* are hard to predict, because they are usually caused when the software makes an assumption on the environment that isn't always true.

Examples:

* A bug in the Linux kernel that caused applications to hang due to the leap second on June 30, 2012
* A runaway process that uses shared resources (CPU time, memory, disk space, network bandwidth)
* A dependent service stops working
* Cascading failures, when a component's fault causes another fault in another component, which cause another failut in another component, etc.

#### Human Errors

Humans are unreliable, even when they try their best not to be.

Ways systems can be reliable in spite of this:

* Design systems to minimize opportunities for error. A well designed API, admin interfaces, permission control, etc.
* Decouple the place where humans makes the most errors and the place where failures can occur. Create a *sandbox* environment to allow humans to experiment, for example.
* Test at all levels. Unit testing, integration testing, manual testing, etc.
* Allow quick and easy recovery from human errors
* Have proper monitoring. Performance metrics, error rates, etc.
* Good management practices and training. This is beyond the scope of a developer.

#### Why is Reliablity Important?

It isn't only important for air traffic controllers or nuclear power stations. If a system isn't reliable, it can cause loss of productivity, loss of revenue, and damages reputations.

There are cases where we can give up reliability in order to save development costs (such as when you're prototyping) or operational costs (for when the benefits are super marginal). **We need to be very conscious and deliberate with these decisions**.

### Scalability

*Scalability* is basically **the ability to cope with increased load**.

*Scalability* isn't an attribute of a system, as in you can't say "System X is scalable". It is more along the lines "if System X grows in this particular way, how can it cope with it?". A system can be scalable in one way and not in the other.

#### Describing Load

We need to be able to describe our load before we can try to handle load growth.

*Load parameters* are numbers that describe the load. The parameters chosen depend on the architecture of your system. It can be requests/sec, read/write ratio, number of users online, cache rates, etc.

Also the values to consider depends on use case. Maybe the average value of the load is all you need to handle, maybe is specific extreme values.

##### Example - Twitter

Twitter has two main operations:

1. Post tweet - 4.6K requests/sec (avg), 12K requests/sec (peak)
1. Home timeline - 300K requests/sec

We can handle the posting tweet peak of 12K requests/sec - pretty straightforward. However, *that isn't Twitter's scaling challenge*. The main issue isn't tweet volume, it is the *getting all users that a user follows and sharing updates from a user to all of their followers* (aka the home timeline).

Two examples of handling these operations:

1. Have a global collection of tweets. 
    * Post tweet - add to the global selection. 
    * Home timeline - get all users they follow, merge all of their tweets and sort by time.
1. Have a cache for each user's hometimeline.
    * Post tweet - find all users that follow this user and push the tweet to each of their caches
    * Home timeline - read the cache

Twitter first implemented approach 1, but they struggled with home timeline queries as users began to increase, so they switched to approach 2. It made more sense because the rate of home timelines was way higher than the rate of posting a tweet.

This does make posting tweets more expensive. 4.6K requests/sec, with an average of 75 followers results in 345K writes/sec to the home timeline caches. Some users have way more than 75 followers. If a celebrities has 30 million followers, meaning a single tweet can cause 30 million writes! Doing this in a decent time (Twitter likes to have it in 5 seconds) is challenging.

**The distribution of followers per user is the key load parameter** for Twitter.

Twitter is actually moving to a hybrid approach. It implements approach 2 for most users. Those with high number of followers are not handled the same way and rather uses something like approach 1.

#### Describing Performance

Once we have described the load on our system, we can see how increased load affects the system. Two ways to look at it:

1. When we increase a load parameter and do not change the system resources (CPU, memory, network bandwidth, etc), how is performance in our system impacted?
1. When we increase a load parameter, how much do we need to change the system resources to keep the performance unchanged?

We first need to understand how to describe performance.

In a batch processing system (e.g. Hadoop), we usually care about *throughput* - the # of records we can process in a second, or total time a job takes to run on a dataset of a certain size.

In online systems, what we usually care about is the service's *response time* - the time between a client sending a request and getting a response. Response time varies between each call so rather than looking at a number, we look at *a distribution*.

> Variation in reponse time can be caused by many things, even when you expect the response time to be exactly the same. CPU load on the system by other processes, temperature of the server, disk speed impacted by the vibrations, literally anything and everything can affect the time.

The *median* is a good representation of the typical response time. *Percentiles* are good ways to measure, as opposed to the mean (which can be skewed by outliers). Medians tells us that half of the calls are below the time, half are above.

> Ex. Lets say the response time with a sample of 5 is 1,1,1,1,100 seconds. The mean is 20.8 seconds while the median is 1 second. 20.8 seconds doesn't accurately describe our system in anyway, while the median of 1 tells us that on average we can expect 1 second response time. This makes sense looking at our sample.

If we want to see how bad our outliers are, we can look at higher percentiles. 95%, 99%, and 99.9% are common metrics because of this case.

> Let's say our 50% percentile metric (a.k.a media) is 1 second but our 95% is 10 seconds. This means that 95 out of 100 times the repsonse will take less than 10 seconds, but 5 out of 100 it'll take more than 10 seconds.

These higher percentiles of response times, *tail latencies*, are important because it directly affects users' experience.

> Ex. Amazon looks at 99.9% percentile because the calls that take the longest are usually by clients with the most data on their accout because they have made a lot purchases - so are very valuable customers. It is important to make sure that they are happy with the service. Amazon didn't think it was worth dealing with the 99.99% percentile however, because the cost of handling those cases outweighed the benefits.

Percentiles are used in *service level objectives (SLOs)* and *service level agreements (SLAs)*, contracts that define the expected performance and availability of a service.

> Ex. An SLA may state that a service is considered to up up if it has a median repsonse time of less than 200ms and a 99th percentile under 1s, and the service is required to be up at least 99% of the time.

Queue delays account for a large part of the response time. A server can only process a set amount of items in parallel (e.g. determined by the number of CPUs it has). It takes a certain amount of requests before other requests are held up. This is known as *head-of-line blocking*. Even if a single request takes no time at all, it make take a long time because it is waiting on other requests to be handled. Because of this **it is important to measure the response time on the client side**.

When testing load, the client sending the test load should send the requests independently of the response time. If the client waits for a previous request before sending another, it essentially shortens the queue, making the tests use a shorter queue than what we would see in reality.

#### Approaches for Coping with Load

An architecture that designed to hold a certain load is unlikely to hold 10x that load.

Two ways to scale:

* *scale up* - move to a more powerful machine. Single machine system is simpler, but can get really expensive.
* *scale out* - move to multiple, smaller machines.

Usually scaling involves a mixture of both.

*Elastic* system - a system that can add computing resources automatically as it detects a load increase. This is opposed to a system scaling *manually* - where a human adds the resources when needed. An *elastic* system is useful if the load is highly unpredictable, but manually scaled systems are simpler.

Taking a stateful data system from one node to multiple can introduce a lot of complexity. So usually, it is common to *scale up* until it becomes too expensive, at which point, scale out.

The architecture of a system that operates at a large scale is usually geared toward a specific application. There is no *magic scaling sauce*. The problem could be volume of reads, write, computations, access pattern, or something else - making a scaling architecture to handle any case isn't really feasible. (Or if you do, it  may be unnecessarily complicated.)

Scalable architectures, although specific to specific applications, are usually built from general-purpose building blocks, arranged into familiar patterns.

### Maintainability

We should design software in a way that will minimize pain during maintenance. Maintenance is an unavoidable part of software development, and probably has more work done than the actual development itself (due to bug fixes, investigating failures, adapting new tech, etc.) There are three principles, with this in mind:

* *Operability* - Easy to keep the system running
* *Simplicity* - Easy for new engineers to understand the system by removing as much complexity as possible
* *Evolvability* - Easy to make changes to the system, adapting it for unanticipated use cases as requirements change.

#### Operability: Making Life Easy for Operations

A good operations team is responsible for the following and more. (This is basically a list, not much worth in memorzing. Just get a feeling of what things to think about.)

* Monitoring health and quickly restoring the health of the service if it went bad
* Tracking down the cause of problem
* Keeping software and platform up to date
* Keeping tabs on how different systems affect each other (to avoid problematic changes)
* Anticipating future problems and solving them before they occur
* Establishing good practices and tools for development, configuration management, etc
* Performing complex maintenance tasks
* Maintaining the security of the system
* Defining processes that make operations predictable and keep prod stable
* Preserve the org's knowledge, even as members leave

Data systems can do various things to make routine tasks easy, including:

* Provide visibility into runtime behavior and internals of the system, **good monitoring**
* Provide support for automation and integration with standard tools
* Avoid dependency on individual machines (so machines can be taken down for maintenance)
* Documentation, operational model ("If I do X, Y will happen")
* Provide good default behavior, but allow defaults to be overridden
* Self healing when applicable, but allow manual control over the system too
* Exhibiting predictable behavior.

#### Simplicity: Managing Complexity

Code gets complex and hard to understand as a project gets bigger. This is almost inevitable.

Various symptoms:

1. Explosion of the state space
1. Tight coupling of modules
1. Tangled dependencies
1. Inconsistent naming and terminology
1. Hacky work
1. Etc

**Making a system simpler doesn't necessarily mean reducing its functionality.** It can also mean removing accidental complexity.

*Accidental complexity* - Complexitiy that isn't inherent in the problem that the software solves, but arises only from the implementation.

*Abstraction* is one of the best tools to remove accidental complexity. It can hide a lot of implementation details behind a clean facade.

Finding good abstractions is very hard though.

#### Evolvability: Making Change Easy

System's requirement will most likely be in constant flux.

Nothing else to note here...
