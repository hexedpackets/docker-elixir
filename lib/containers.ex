defmodule Docker.Containers do
  @moduledoc """
  Docker containers methods.
  """
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
    Logger.debug fn -> "Decoding Docker API response: #{Kernel.inspect body}" end
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
    Logger.debug fn -> "Decoding Docker API response: #{Kernel.inspect body}" end
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
    with 201 <- status_code,
        {:ok, res} <- Poison.decode(body) do
      {:ok, res}
    else
      400 -> {:error, "Bad parameter"}
      404 -> {:error, "No such container"}
      406 -> {:error, "Impossible to attach"}
      409 -> {:error, "Conflict"}
      500 -> {:error, "Server Error"}
      _ -> {:error, "Unknown error #{Kernel.inspect(body)}"}
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
    Logger.debug fn -> "Decoding Docker API response: #{Kernel.inspect body}" end

    case status_code do
      204 -> {:ok}
      304 -> {:error, "Container already stopped"}
      404 -> {:error, "No such container"}
      500 -> {:error, "Server error"}
      _   -> {:error, "Unknow status"}
    end
  end

  @doc """
  Kill a running container.
  """
  def kill(id) do
    "#{@base_uri}/#{id}/kill" 
    |> Docker.Client.post
    |> decode_kill_response
  end

  defp decode_kill_response(%HTTPoison.Response{status_code: status_code}) do
    case status_code do
      204 -> {:ok}
      304 -> {:error, "Container already killed"}
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

  @doc """
  Given the name of a container, returns any matching IDs.
  """
  def find_ids(name, :partial) do
    {:ok, containers} = Docker.Containers.list
    name = name |> Docker.Names.container_safe |> Docker.Names.api
    ids =
      containers
        |> Enum.filter(&(match_partial_name(&1, name)))
        |> Enum.map(&(&1["Id"]))
    case length(ids) > 0 do
      true -> {:ok, ids}
      _ -> {:err, "No containers found"}
    end
  end
  def find_ids(name) do
    {:ok, containers} = Docker.Containers.list
    name = name |> Docker.Names.container_safe |> Docker.Names.api
    ids =
      containers
      |> Enum.filter(&(name in &1["Names"]))
      |> Enum.map(&(&1["Id"]))
    case length(ids) > 0 do
      true -> {:ok, ids}
      _ -> {:err, "No containers found"}
    end
  end

  defp match_partial_name(container, name) do
    container["Names"]
    |> Enum.any?(&(&1 == name || String.starts_with?(&1, "#{name}_")))
  end

end
