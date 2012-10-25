# Redis subscribe proxy

This is a proxy of Redis for SUBSCRIBE.

In typical situation of using Pub/Sub of Redis, you want to subscribe many channels on a single process.

But that makes you to create many clients resulting EMFILE error.

This module proxies many SUBSCRIBE clients to a single Redis connection.

# usage
    var proxy = require("redis-sub-proxy"),
        connection, sub1, sub2;

    connection = proxy.createConnection(6379, 'localhost'); // extention of redis.RedisClient

    sub1 = connection.createClient();
    sub1.subscribe('chat:room1')
    sub1.on("message", function(ch, msg){ console.log("sub1: ", ch, msg) })

    sub2 = connection.createClient();
    sub2.subscribe('chat:room2')
    sub2.on("message", function(ch, msg){ console.log("sub2: ", ch, msg) })
