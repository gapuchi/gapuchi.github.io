# Reverse Proxy

Reverse Proxy
: Web server that centralizes internal services and provides a unified interface to the public. Requests from clients are forwarded to the appropriate server and then the reverse proxy returns the response to the customer.

Benefits:

* Increased security - Abstract backend, block IPs, limit connections, etc.
* Increased scalability and flexibility - Servers are hidden behind the reverse proxy's IP address. We can add/modify servers with ease.
* SSL termination
* Compression - compress server responses
* Caching - Return the response for cached requests
* Static content - Serve static content directly

**Load Balancer vs Reverse Proxy**

- LB is useful when you have multiple servers with the same functionality
- Reverese Proxy is useful even if you have one for the above benefits.
  
Solutions like NGINX and HAProxy can support both.

## Cons

- Increased complexity to the system.
- Single point of failure. Can be mitigated with multiple reverse proxies (i.e. adding failovers), which also adds complexity.