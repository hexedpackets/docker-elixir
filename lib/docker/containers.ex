defmodule Docker.Containers do
  require Logger
  @base_uri "/containers"

  @doc """
  List all existing containers.
  """
  def list do
    "#{@base_uri}/json?all=true"
    |> Docker.Client.get
    |> decode_list_response
  end

  defp decode_list_response(%HTTPoison.Response{body: body, status_code: status_code}) do
    Logger.debug "Decoding Docker API response: #{Kernel.inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          200 -> {:ok, dict}
          400 -> {:error, "Bad parameter"}
          500 -> {:error, "Server error"}
          code -> {:error, "Unknown code: #{code}"}
        end
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Inspect a container by ID.
  """
  def inspect(id) do
    "#{@base_uri}/#{id}/json"
    |> Docker.Client.get
    |> decode_inspect_response
  end

  defp decode_inspect_response(%HTTPoison.Response{body: body, status_code: status_code}) do
    Logger.debug "Decoding Docker API response: #{Kernel.inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          200 -> {:ok, dict}
          404 -> {:error, "No such container"}
          500 ->
            Logger.error(Kernel.inspect(body))
            {:error, "Server error"}
          code -> {:error, "Unknown code: #{code}"}
        end
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Create a container from an existing image.
  """
  def create(conf) do
    "#{@base_uri}/create"
    |> Docker.Client.post(conf)
    |> decode_create_response
  end
  def create(conf, name) do
    "#{@base_uri}/create?name=#{name}"
    |> Docker.Client.post(conf)
    |> decode_create_response
  end

  defp decode_create_response(%HTTPoison.Response{body: body, status_code: status_code}) do
    Logger.debug "Decoding Docker API response: #{Kernel.inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          201 -> {:ok, dict}
          400 -> {:error, "Bad parameter"}
          404 -> {:error, "No such container"}
          406 -> {:error, "Impossible to attach"}
          409 -> {:error, "Conflict"}
          500 ->
            Logger.error(Kernel.inspect(body))
            {:error, "Server error: #{dict.message}"}
          code ->
            Logger.error(Kernel.inspect(body))
            {:error, "Unknown code: #{code}"}
        end
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Remove a container. Assumes the container is already stopped.
  """
  def remove(id) do
    "#{@base_uri}/#{id}"
    |> Docker.Client.delete
    |> decode_remove_response
  end

  defp decode_remove_response(%HTTPoison.Response{status_code: status_code}) do
    case status_code do
      204 -> {:ok}
      400 -> {:error, "Bad parameter"}
      404 -> {:error, "No such container"}
      409 -> {:error, "Conflict"}
      500 -> {:error, "Server error"}
      code -> {:error, "Unknown code: #{code}"}
    end
  end

  @doc """
  Starts a newly created container.
  """
  def start(id) do
    start(id, %{})
  end

  @doc """
  Starts a newly created container with a specified start config.
  The start config was deprecated as of v1.15 of the API, and all
  host parameters should be in the create configuration.
  """
  def start(id, conf) do
    "#{@base_uri}/#{id}/start"
    |> Docker.Client.post(conf)
    |> decode_start_response
  end

  defp decode_start_response(%HTTPoison.Response{status_code: status_code}) do
    case status_code do
      204 -> {:ok}
      304 -> {:error, "Container already started"}
      404 -> {:error, "No such container"}
      500 -> {:error, "Server error"}
      code -> {:error, "Unknown code: #{code}"}
    end
  end

  @doc """
  Stop a running container.
  """
  def stop(id) do
    "#{@base_uri}/#{id}/stop"
    |> Docker.Client.post
    |> decode_stop_response
  end

  defp decode_stop_response(%HTTPoison.Response{body: body, status_code: status_code}) do
    Logger.debug "Decoding Docker API response: #{Kernel.inspect body}"

    case status_code do
      204 -> {:ok}
      304 -> {:error, "Container already stopped"}
      404 -> {:error, "No such container"}
      500 -> {:error, "Server error"}
      code -> {:error, "Unknown code: #{code}"}
    end
  end

  @doc """
  Restart a container.
  """
  def restart(id) do
    "#{@base_uri}/#{id}/restart"
    |> Docker.Client.post
    |> decode_start_response # same responses as the start endpoint
  end
end
