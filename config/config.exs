use Mix.Config

config :logger, level: :debug
config :docker, host: "http+unix://%2Fvar%2Frun%2Fdocker.sock"
config :docker, version: "v1.27"
