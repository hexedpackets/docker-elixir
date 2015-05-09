use Mix.Config

config :logger, level: :info

config :docker, host: System.get_env("DOCKER_HOST") |> String.replace("tcp://", "http://")
config :docker, version: "v1.18"
