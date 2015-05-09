# docker-elixir
Elixir client for the Docker Remote API using HTTPoison.

Currently the client only supports having Docker listen on a TCP port, not a Unix socket.
This can be enabled with the flag the -H flag, e.g. `-H 127.0.0.1:2735`.

