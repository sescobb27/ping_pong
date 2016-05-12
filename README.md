ping_pong
=====

An OTP application

Build
-----

    $ rebar3 compile

WORKLOAD
```bash
go get github.com/rakyll/boom
boom -cpus=8 -n=10000 -c=100 http://localhost:4001/ping
```
