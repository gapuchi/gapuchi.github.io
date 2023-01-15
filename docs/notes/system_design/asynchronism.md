# Asynchronism

Async workflows help reduce times for expensive operations.

> Is this really true? It's not that it reduces times for expensive operations, it just reduces the API latency by doing it outside of the request.

## Message Queues

Message Queue
: Receives, holds, and delivers messages.

Common arch pattern:

1. App publishes a job to the queue, returns to the user a job status.
2. A worker picks up the job from the queu, processes it, then signals the job is complete.

User doesn't wait for the API call to perform the job, just the time for the API to put it into the queue.

Redis is useful as a simple message broker but messages can be lost.

RabbitMQ requires you to adapt the `AMQP` protocol and manage your own nodes.

Amazon SQS is hosted but can have higer latency and has at least one deliver.

## Task Queues (Workers?)

???

## Back Pressure

If items are placed in a queue at a rate more than the workers consuming them, the queue can grow large.

Back pressure limits the queue size to help maintain throughput.

When a queue gets full, clients gets a server busy or HTTP 503 to try again later.

## Cons of Async

Adds delays and complexity, so shouldn't be used for simple operations.