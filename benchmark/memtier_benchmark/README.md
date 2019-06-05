Memtier\_benchmark
==================
ref: <https://github.com/RedisLabs/memtier_benchmark>

Build
-----
```
apt-get install build-essential autoconf automake libpcre3-dev libevent-dev pkg-config zlib1g-dev
autoreconf -ivf
./configure
make
sudo make install
```

Run
---
### Example
ref: <https://stackoverflow.com/questions/41514478/memtier-benchmark-understanding-the-output>
```
memtier_benchmark -s localhost -p 7000 -c 50 -t 100 -n 1000 -d 1000000 --ratio=1:1 --pipeline=1 --key-pattern S:S -P redis
```

### Usage
ref: `$ man memtier_benchmark`

```
memtier_benchmark [options]

   Connection and General Options:
       -s, --server=ADDR
              Server address (default: localhost)

       -p, --port=PORT
              Server port (default: 6379)

       -P, --protocol=PROTOCOL
              Protocol to use (default: redis).  Other supported protocols are memcache_text, memcache_binary.

       --hide-histogram
              Don't print detailed latency histogram

       --out-file=FILE
              Name of output file (default: stdout)

   Test Options:
       -n, --requests=NUMBER
              Number of total requests per client (default: 10000) use 'allkeys' to run on the entire key-range

       -c, --clients=NUMBER
              Number of clients per thread (default: 50)

       -t, --threads=NUMBER
              Number of threads (default: 4)

       --ratio=RATIO
              Set:Get ratio (default: 1:10)

       --test-time=SECS
              Number of seconds to run the test

       --pipeline=NUMBER
              Number of concurrent pipelined requests (default: 1)

       --distinct-client-seed
              Use a different random seed for each client

       --randomize
              random seed based on timestamp (default is constant value)

   Object Options:
       -d  --data-size=SIZE
              Object data size (default: 32)

   Key Options:
       --key-maximum=NUMBER
              Key ID maximum value (default: 10000000)
              
       --key-pattern=PATTERN
              Set:Get pattern (default: R:R) G for Gaussian distribution.  R for uniform Random.  S for  Sequential.   P  for
              Parallel (Sequential were each client has a subset of the key-range).

```

