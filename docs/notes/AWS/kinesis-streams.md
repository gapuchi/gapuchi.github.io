# Amazon Kinesis Data Streams

Kinesis Data Streams can be used to collect and process large streams of data records in real time.

Kinesis Data Stream
: A set of *shards*. Each shard has a sequence of *data records*. Each data record has a sequence number.

Data Record
: A unit of data stored in a Kinesis data stream. It is a composition of a sequence number, partition key, and a data blob.

Shard
: A uniquely identified sequence of data records in a stream. Each shard provides a unit of capacity (5 TPS reads, total 2MB/sec, 1000 records/sec writes, total 1MB/sec write)
