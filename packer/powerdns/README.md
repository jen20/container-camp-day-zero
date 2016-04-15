PowerDNS Packer Template
========================

This template builds a PowerDNS container using Packer, configured using the sqlite3 back end with records for `hashicorptest.com`.

It can be run using:

```shell
$ docker run --rm -p 53:53/udp -p 53:53/tcp -p 8081:8081 terraform/test:1.0 /usr/sbin/pdns_server
```

This is intended for use as part of the Travis CI build for Teraform.
