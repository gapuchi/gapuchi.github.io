# System design

**Big picture:** start with requirements and a sketch, then the tradeoffs, then the components that show up in almost every design.

## Reading order

1. [Approach](0-general-approach.md): requirements, rough numbers, API, data, then a high-level and a low-level design.
2. [Tradeoffs](1-general-considerations.md): performance against scalability, latency against throughput, consistency against availability.
3. [Scalability](scalability.md): growing the work a system can take.
4. [Load balancer](load-balancer.md): spreading requests across instances.
5. [Reverse proxy](reverse-proxy.md): a single front door that forwards inward.
6. [Cache](cache.md): keeping a copy closer than the source of truth.
7. [CDN](content-delivery-network.md): that copy, pushed out to the edge.
8. [Databases](databases.md): where the durable state lives, and how you choose.
9. [Asynchronism](asynchronism.md): doing the work later, off the request.

## Related

- [Transactions](../database/transactions.md): what a later read is allowed to observe.
