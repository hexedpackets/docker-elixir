defmodule Docker.Auth do
  @default_server "https://index.docker.io/v1/"

  @doc """
  Authenticate to the Docker registry.
  """
  def login(credentials = %{"email" => _email, "password" => _password, "username" => _username, "serveraddress" => _server}) do
    data = Jason.encode!(credentials)
    Docker.Client.post("/auth", data)
  end

  def login(credentials) do
    credentials
    |> Map.put("serveraddress", @default_server)
    |> login()
  end
end
