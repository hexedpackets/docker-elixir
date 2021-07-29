# docker-elixir

![Hex.pm](https://img.shields.io/hexpm/v/docker)

Elixir client for the Docker Remote API using HTTPoison.


## Docker endpoint

By default, the client will attempt to connect to Docker on the unix socket path `/var/run/docker.sock`. This can be overridden with either an HTTP endpoint or different path by either setting the `DOCKER_HOST` environmental variable, or as a config option:

```elixir
config :docker, host: "http://localhost:2561"
```
