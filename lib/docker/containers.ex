defmodule Docker.Containers do
  @base_uri "/containers"

  @doc """
  List all existing containers.
  """
  def list do
    "#{@base_uri}/json?all=true" |> Docker.Client.get
  end

  @doc """
  Inspect a container by ID.
  """
  def inspect(id) do
    "#{@base_uri}/#{id}/json" |> Docker.Client.get
  end

  @doc """
  Stop a running container.
  """
  def stop(id) do
    "#{@base_uri}/#{id}/stop" |> Docker.Client.post
  end

  @doc """
  Restart a container.
  """
  def restart(id) do
    "#{@base_uri}/#{id}/restart" |> Docker.Client.post
  end

  @doc """
  Remove a container. Assumes the container is already stopped.
  """
  def remove(id) do
    "#{@base_uri}/#{id}" 
    |> Docker.Client.delete
    |> decode_response
  end

  @doc """
  Create a container from an existing image.
  """
  def create(conf) do
    "#{@base_uri}/create"
    |> Docker.Client.post(conf)
    |> decode_response
  end
  def create(conf, name) do
    "#{@base_uri}/create?name=#{name}"
    |> Docker.Client.post(conf)
    |> decode_response
  end

  @doc """
  Starts a newly created container.
  """
  def start(id) do
    Docker.Client.post("#{@base_uri}/#{id}/start", %{})
  end

  @doc """
  Starts a newly created container with a specified start config.
  The start config was deprecated as of v1.15 of the API, and all
  host parameters should be in the create configuration.
  """
  def start(id, conf) do
    Docker.Client.post("#{@base_uri}/#{id}/start", conf)
  end

  defp decode_response(%HTTPoison.Response{body: "", status_code: status_code}) do
    case status_code do
      x when x in 200..299 ->
        {:ok}
      _ ->
        {:error}
    end
  end
  defp decode_response(%HTTPoison.Response{body: body, status_code: status_code}) do
    # Logger.debug "Decoding Docker API response: #{inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          x when x in 200..299 ->
            {:ok, dict}
          _ ->
            {:error, dict}
        end
      {:error, message} ->
        {:error, message}
    end
  end
end
