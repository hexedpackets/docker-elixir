defmodule Docker.Auth do
  @default_server "https://index.docker.io/v1/"

  @doc """
  Authenticate to the Docker registry.
  """
  def login(credentials = %{"email" => _email, "password" => _password, "username" => _username, "serveraddress" => _server}) do
    data = Poison.encode!(credentials)
    Docker.Client.post("/auth", data)
  end

  def login(credentials) do
    credentials
    |> Dict.put("serveraddress", @default_server)
    |> login
  end
end
