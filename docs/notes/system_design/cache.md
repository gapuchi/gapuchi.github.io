# Cache

Caching can reduce load on servers and databases.

## Where Caching Resides

- Client side - OS, browser
- CDN - CDN is considered a type of cache
- Web Server - Reverse proxies can serve static and dynamic content directly. Web servers can also cache requests and their responses.
- Database - DB's usually have some default caching set up.
- Application - In-memory caches such as memcached and Redis are key-value data held in RAM. RAM is more limited than disk so invalidation algorithms are important (e.g. LRU)

## Categories of Caching

There are multiple levels of caching that fall into two general categories: db queries and objects.

### Database Query Level

Hash the query as a key and store the result in the cache.

Cons
- If an item changes, you need to delete all cached keys involving that item.
- Hard to delete a cached result with complex queries

### Object Level

Store data as an object/data structure. Remove if the data has changed. Allow for async processing - workers can assemble objects by using the cache (?)

## Updating the Cache

### Cache-Aside

![Cache Aside Diagram](/img/cache-aside.png)

The application is responsible for reading and writing from storage. Cache doesn't work with storage directly.

The application:

- Looks in cache
- Looks in DB
- Adds to cache
- Returns result

Memcached is used this way.

Cons

- Cache miss has a delay (added cost of read from DB, write to cache)
- Data can get stale if updated in DB. Mitigated by a TTL or write-through
- When a node fails, it is replaced with an empty node.

### Write-Through

Application interacts with the cache as the DB, writing and reading data to it. The cache is responsible for reading and writing to the database.

Write-through is slow because of the write operation, but reads are fast. This is okay generally since users are more tolerant of latency when updating data  than reading data. Data in the cache are not stale (when it gets updated, it'll update in the cache)

Cons

- New node will not cache until item is updated. Mitigated by also adding cache-aside
- Most data written might be never read. Mitigated with a TTL.

### Write-Behind (Write-Back)

![Write-behind Cache Diagram](/img/write-behind-cache.png)

It's like write-through but writes are async.

Cons

- Data loss if cache goes down before data hits data store.
- Complex compared to other approaches.

### Refresh-Ahead

> This can be used in the other caching methods above.

Configure the cache to automatically refresh any recently accessed cache entry porior to its expiration.

- Reduce latency vs read-through **if** it can predice what items will be read.

Cons

- Not accurate predictions result in reduced performance.

## Cons of Cache

- Need to maintain consistency with source of truth, using cache invalidation, which is a difficult problem.

`TODO Cache Invalidation`