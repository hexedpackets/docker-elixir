defmodule Docker.Client do
  @socket_path "unix:///var/run/docker.sock"
  @default_version "v1.36"

  defp base_url() do
    host = Application.get_env(:docker, :host) || System.get_env("DOCKER_HOST", @socket_path)
    version =
      case Application.get_env(:docker, :version) do
        nil -> @default_version
        version -> version
      end


    "#{normalize_host(host)}/#{version}"
    |> String.trim_trailing("/")
  end

  defp normalize_host("tcp://" <> host), do: "http://" <> host
  defp normalize_host("unix://" <> host), do: "http+unix://" <> URI.encode_www_form(host)

  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url()},
      Docker.ChunkedJson,
    ]
    Tesla.client(middleware, Tesla.Adapter.Hackney)
  end

  @doc """
  Send a GET request to the Docker API at the speicifed resource.
  """
  def get(resource, opts \\ []) do
    Tesla.get!(client(), resource, opts) |> Map.get(:body)
  end

  @doc """
  Send a POST request to the Docker API, JSONifying the passed in data.
  """
  def post(resource, data \\ %{}, opts \\ []) do
    Tesla.post!(client(), resource, data, opts) |> Map.get(:body)
  end

  @doc """
  Send a DELETE request to the Docker API.
  """
  def delete(resource, opts \\ []) do
    Tesla.delete!(client(), resource, opts)
  end
end
