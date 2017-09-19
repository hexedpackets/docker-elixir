defmodule Docker.Auth do
  @moduledoc """
  Regroup docker auth stuffs
  """
  @doc """
  Authenticate to a docker registry.
  """
  def login(credentials) do
    Docker.Client.post("/auth", credentials)
  end
end
