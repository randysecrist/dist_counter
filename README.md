# Distributed Counter (a Simple CRDT Database)
[![Build Status](https://travis-ci.org/randysecrist/dist_counter.svg?branch=master)](https://travis-ci.org/randysecrist/dist_counter)

This is a simple [pncounter](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#PN-Counter_.28Positive-Negative_Counter.29) API implementation using [riak_dt](https://github.com/basho/riak_dt).

It exposes the following HTTP routes:

```
/ping {GET}
/config {GET/POST}
/counter/name {POST}
/counter/value {GET}
/counter/consistent_value {GET}
```

## Building

This software requires [Erlang OTP 20](https://github.com/erlang/otp/releases/tag/OTP-20.0) and [Elixir 1.5.1](https://github.com/elixir-lang/elixir/releases/tag/v1.5.1).  Knowledge of building and setting those up is assumed but I would suggest [erln8](erln8) if working outside of docker.

The standard elixir mix workflow applies:

```bash
# Get Dependencies
mix deps.get

# Compile
mix compile
```

Each node should have a ```CHALLENGE_ID```.  This is passed in via environment variable.  If it is not passed, each node's id will be set to ```DEFAULT```.

## Starting a Node
``` CHALLENGE_ID=<integer> iex -S mix ```

There is also a bash script in bin/ called ```challenge-executable.sh``` which starts and backgrounds the application.  This should be invoked with a integer argument and this script will in turn set the ```CHALLENGE_ID``` environment variable.

```MIX_ENV={dev,test,prod}``` may also be used to describe which configuration environment to point to.  The default is ```dev```.

```ACTORS="{\"actors\":[\"counter1\", \"counter2\", \"counter3\"]}"``` can also be passed as an environment variable.  Docker Compose does this automatically.  The /config POST mechanism overrides this environment variable and can be used to add an actor at runtime.  Note that each node needs to be sent the configuration.

## Docker Compose

The following commands will start a three node cluster and connect them all together.

```bash
docker-compose up -d
```

The nodes will be exposed on ports ```7777```, ```8888```, and ```9999```.

The following will stop/start individual nodes to easily facilitate testing partitions.

```docker stop counter3```

## Docker Container (Manual)

The following commands will pull a docker image and setup a 3 node environment.

```bash
# pull and run the image
docker pull randysecrist/dist_counter
docker run -d -p 7777:7777 -h one -e CHALLENGE_ID=1 randysecrist/dist_counter:latest
docker run -d -p 8888:7777 -h two -e CHALLENGE_ID=2 randysecrist/dist_counter:latest
docker run -d -p 9999:7777 -h three -e CHALLENGE_ID=3 randysecrist/dist_counter:latest

# get IP addresses to configure the nodes.
docker inspect -f '{{.NetworkSettings.IPAddress}}:7777' $(docker ps -aq)

# let each node how to find each other
curl -X POST http://localhost:7777/config -d "{\"actors\": [\"172.17.0.2\", \"172.17.0.3\", \"172.17.0.4\"]}"
curl -X POST http://localhost:8888/config -d "{\"actors\": [\"172.17.0.2\", \"172.17.0.3\", \"172.17.0.4\"]}"
curl -X POST http://localhost:9999/config -d "{\"actors\": [\"172.17.0.2\", \"172.17.0.3\", \"172.17.0.4\"]}"

# verify each node
curl http://localhost:7777/ping
curl http://localhost:7777/config
```

## Testing
```bash
curl -X POST http://localhost:7777/counter/mycount -d "2"
curl -X POST http://localhost:9999/counter/mycount -d "2"

# should return an answer of 4 if all nodes are up
curl http://localhost:8888/counter/mycount/value
```
### Process Failure

Counter state is flushed to disk every 5 seconds (configurable) per node.  This means that if a process dies then some data may be lost.  Nodes also attempt to merge counter data with each other during this save.

### Network Partitions

The ```/counter/:name/value``` endpoint will always try to return the best answer possible regardless of which nodes are down.

The ```/counter/:name/consistent_value``` endpoint will only return an answer if all nodes are available.

### Cluster Healing & Cron Jobs

Every minute a node in the cluster will attempt to connect to peer actor nodes.  When a cluster change is detected then cron jobs will rebalance accordingly.  Some jobs run on each node always (saving state) while others are intended to just run on one random node in the cluster.
