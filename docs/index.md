
# lua-Spore

---

## Overview

lua-Spore is an implementation of
[SPORE](https://github.com/SPORE/specifications)
(Specification to a POrtable Rest Environment) which is a
[RESTful API Description Language](https://en.wikipedia.org/wiki/Overview_of_RESTful_API_Description_Languages)
with a generic client implementation based on pluggable [middlewares](middleware).

## References

Some specifications of service are available at
[https://github.com/SPORE/api-description](http://github.com/SPORE/api-description).

## Status

lua-Spore is in beta stage.

It's developed for Lua 5.1, 5.2, 5.3 & 5.4.

## Download

The sources are hosted on [Framagit](https://framagit.org/fperrad/lua-Spore).

## Installation

lua-Spore is available via LuaRocks:

```sh
luarocks install lua-spore
```

or manually (LuaSocket and LuaJSON required), with:

```sh
make install
```

## Test

The test suite requires the module
[lua-TestAssertion](https://fperrad.frama.io/TestAssertion/).

```sh
make test
```

## Copyright and License

Copyright &copy; 2010-2018 Fran&ccedil;ois Perrad

This library is licensed under the terms of the MIT/X11 license,
like Lua itself.
