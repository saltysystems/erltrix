erltrix
=====
```
 ____  _______  _____
|   _||    ___||_   |
|  |  |   |___   |  |
|  |  |    ___|  |  |
|  |_ |   |___  _|  |
|____||_______||____|
```

Erlang Matrix Lib

Build
-----

```
    $ rebar3 compile
```

Run
-----

You should export the following environment variables before launching Erltrix

| ENV Var | Default | Purpose |
| ------- | ------- | ------- |
| `ERLTRIX_HOST` | localhost.localdomain | Hostname of your Matrix server |
| `ERLTRIX_USER` | @vendor:localhost.localdomain | Matrix username |
| `ERLTRIX_PASS` | password | Matrix password |
| `ERLTRIX_PORT` | 443 | HTTPS port for the Matrix server |

Then, 

```
    $ rebar3 shell
```
