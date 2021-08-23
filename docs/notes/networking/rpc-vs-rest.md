# RPC vs REST

My notes from Google's blog post on [REST vs RPC](https://cloud.google.com/blog/products/application-development/rest-vs-rpc-what-problems-are-you-trying-to-solve-with-your-apis).

## RPC

Procedure
:  a.k.a functions. Is the dominant construct for organizing computer code. 

Remote Procedure Call (RPC)
:  Is when a computer program causes a **procedure** (function, subroutine) to execute in a different address space. (This is usually on a different computer on a shared network). This procedure is coded as if it were a normal (local) procedure call, without the programmer explicitly coding the details for the remote interaction.

Here is an example of a RPC through HTTP:

```http
POST /SendUserMessage HTTP/1.1
Host: api.example.com
Content-Type: application/json

{"userId": 501, "message": "Hello!"}
```

All modern programming languages use procedures as their central programming construct to produce and consume APIs. Procedures therefore has been the dominant model for designing APIs (in the from of RPC's).

Most times when developers are creating API's, it is because their application is implemented as many distributed components. API's are needed to communicate between these components to function. (Another reason is that a service is being used by multiple components).

RPC's are often used because it prioritizes ease of programming for both clients and the server while being efficient. Making a RPC is syntatically the same as calling a normal function (as if it is was local), and learning the functions of a remote API is similar to learning a new programming library. RPC's are also usually efficient, the data passed between client and server usually being binary and encourages small messages.

## So Why Not RPC?

Two commons with software development:

1. Difficult to change - a lot of (not new) products use legacy code and for a good reason - it is difficult to change. Usually due to assumptions made on the interface or behavior requires a lot of rework of the code. This often leads to the decision that it isn't worth modifying the software but rather using as it and implementing work arounds
1. Difficult to integrate - A service's first implementation of API's usually serve the most basic functionality. However as it develops, there is value in supporting further integrations with other systems (for 3P integration, mobile support, etc). This is inherently hard because the service needs to provide the support with API's, and the integrating application/service needs to provide their own robust API's.

## REST

REpresentational State Transfer (REST)
:  A model for API's. It is an **architectural style** that helped design HTTP (and the world wide web). It defines a set of constraints for how the architecture of an "Internet-scale distributed hypermedia" should behave.

Hypertext Transfer Protocol (HTTP)
:  An application layer protocol for "distributed, collaborative, hypermedia information systems". It is the foundation of data communication for the world wide web.

HTTP is the only commercially important REST API, so for simplicity's sake, we will focus on HTTP and not other REST implementations.

**The HTTP model is the inverse of the RPC model.** In the RPC model, we are aware of procedures, while the entities are hidden behind these procedures. In the HTTP model, we are aware of the entities, while the behaviors of the system are hidden behind the entities (these are side-effects of the creation, update, deletion of these entities).

Every address on the world wide web exposes **the exact same API - HTTP**. That means to navigate the web, we only need to learn a single API! This characteristic allowed the development of a web browser.

There are some API's that claim to be RESTful but layer proprietary concepts on top of HTTP. They use HTTP as a lower level transport layer instead of using HTTP directly as designed. There's a lot of variability in how people use the term "REST" in the context of API's, it's hard to know what they mean unless you're familiar with them.

There's a lot less to learn about API's that use HTTP than those API's that use RPC. RPC is basically learning a programming library, meaning you have to familiarize yourself with various signatures. API's that use HTTP is basically learning a database schema. You just have to learn the table name, columns, and what each means. That is considerably less learning than a programming library. An API that uses HTTP is mostly defined by its data model.

What about querying data? HTTP doesn't itself provide the functionality beside the basic CRUD operations, so you may need to learn additional information on querying, but it is still less than RPCs. (Query syntax is usually simpler here.)

An API that uses HTTP simply and directly, it will only need to document a couple of things:

1. A limited number of fixed, well-known URLs. Analogous to table names
1. The information model of each of its resource. Analogous to column names.
1. An indication of the supported subset of HTTP (few APi's implement every feature of the protocol)
1. (Optional) Some sort of query syntaqx that enables efficient access to resource data without retrieving the whole item.

## Why HTTP?

1. Ease of integration - An application only needs to know one API (HTTP). The data may be different across API's but the means of access is the same. One problem solved with this is management of resources across systems. HTTP provides a standard way of identifying a resource by URL (e.g. http://myapp.gapuchi.com/resource/id/7). This URL is uniquely across the web. RPC's provide identifiers that are unique to their system, meaning users need to define the identity such that it is unique outside of the application.
1. Ease of change - RPC's are popular because of the ease of integration between applications - this also allows the assumptions on use-case or tech to flow from applications too. The introduction of HTTP/REST breaks that flow by forcing a translation from implementation procedures to entity models. This entity model should/is likely to be a conceptual representation of some part of the problem domain. How effective the API decouples the caller from the callee does depend on the skill of the design, but it does introduce some form of decoupling. The entity model usually goes under less changes compared to prodecures - more and more functionality gets added rather than the data itself being changed.

## Why Not HTTP?

Entity-based API's introduces cost in the form of design and implementation complexity and processing overhead. If efficiency is your first priority, RPC may be a better choice.

It is easy to create an HTTP API that doesn't take advantage of HTTPs. Some mistakes could be:

1. Using local ID's rather than URLS to encode references to entities. If clients need to substitute a variable in a URI template to form the URL, then it lost the benefit of HTTP uniform interface. The only common case for URI templates are for encoding queries.
1. Putting version identifiers in all URls. If all your URLs include version identifiers, you are probably using local identifiers instead of URLs to represent relationships, which is the first mistake.
1. Confusing identity with lookup. All entities have an immutable identity in the form of an URI. It is also a common to reference an entity by its mutable characteristics. It is important not to confuse an entity's own URI with alias URIs used to reference the same entity via a lookup on its name or other mutable characteristics.

## So What To Choose?

Depends on priorities.

If your goal is to enable communication between two different components that you own and control and processing efficiency is a major concern, then RPC is a good fit.

If your goal is to make your software more malleable by breaking it down into components that are better isolated from each other's assumptions, or to open up your system for future integrations by other teams, then HTTP might be the move.

## References

1. https://cloud.google.com/blog/products/application-development/rest-vs-rpc-what-problems-are-you-trying-to-solve-with-your-apis
1. https://www.smashingmagazine.com/2016/09/understanding-rest-and-rpc-for-http-apis/
1. https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol
1. https://en.wikipedia.org/wiki/Representational_state_transfer
1. https://en.wikipedia.org/wiki/Remote_procedure_call