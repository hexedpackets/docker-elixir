defmodule Docker.Images do
  require Logger

  @base_uri "/images"

  @doc """
  List all Docker images.
  """
  def list do
    "#{@base_uri}/json?all=true" 
    |> Docker.Client.get
    |> decode_list_response
  end

  @doc """
  Return a filtered list of Docker images.
  """
  def list(filter) do
    "#{@base_uri}/json?filter=#{filter}" 
    |> Docker.Client.get
    |> decode_list_response
  end

  defp decode_list_response(%HTTPoison.Response{body: body, status_code: status_code}) do
    Logger.debug "Decoding Docker API response: #{Kernel.inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          200 -> {:ok, dict}
          500 -> {:error, "Server error"}
          _ -> {:error, "Server error"}
        end
      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Pull a Docker image from the repo.
  """
  def pull(image), do: pull(image, "latest")
  def pull(image, tag) do
    url = "#{@base_uri}/create?fromImage=#{image}&tag=#{tag}"
    %HTTPoison.AsyncResponse{id: id} = Docker.Client.stream(:post, url)
    handle_pull(id)
  end

  @doc """
  Pull a Docker image from the repo after authenticating.
  """
  def pull(image, tag, auth) do
    headers = auth_headers(auth)
    url = "#{@base_uri}/create?fromImage=#{image}&tag=#{tag}"
    %HTTPoison.AsyncResponse{id: id} = Docker.Client.stream(:post, url, "", headers)
    handle_pull(id)
  end

  defp auth_headers(auth) do
    %{
      "X-Registry-Auth" => auth |> Poison.encode! |> Base.encode64,
      "Content-Type" => "application/json"
    }
  end

  defp handle_pull(id) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code} ->
        case code do
          200 -> handle_pull(id)
          404 -> {:error, "Repository does not exist or no read access"}
          500 -> {:error, "Server error"}
          _ -> {:error, "Server error"}
        end
      %HTTPoison.AsyncHeaders{id: ^id, headers: _headers} ->
        handle_pull(id)
      %HTTPoison.AsyncChunk{id: ^id, chunk: _chunk} ->
        handle_pull(id)
      %HTTPoison.AsyncEnd{id: ^id} ->
        {:ok, "Image successfully pulled"}
    end
  end

  @doc """
  Pull a Docker image and return the response in a stream. 
  """
  def stream_pull(image), do: stream_pull(image, "latest")
  def stream_pull(image, tag) do
    stream = Stream.resource(
      fn -> start_pull("#{@base_uri}/create?fromImage=#{image}&tag=#{tag}") end,
      fn({id, status}) -> receive_pull({id, status}) end,
      fn _ -> nil end
    )
    stream
  end

  @doc """
  Pull a Docker image and return the response in a stream after authenticating.
  """
  def stream_pull(image, tag, auth) do
    headers = auth_headers(auth)
    stream = Stream.resource(
      fn -> start_pull("#{@base_uri}/create?fromImage=#{image}&tag=#{tag}", headers) end,
      fn({id, status}) -> receive_pull({id, status}) end,
      fn _ -> nil end
    )
    stream
  end

  defp start_pull(url) do
    %HTTPoison.AsyncResponse{id: id} = Docker.Client.stream(:post, url)
    {id, :keepalive}
  end

  defp start_pull(url, headers) do
    %HTTPoison.AsyncResponse{id: id} = Docker.Client.stream(:post, url, "", headers)
    {id, :keepalive}
  end

  defp receive_pull({_id, :kill}) do
    {:halt, nil}
  end
  defp receive_pull({id, :keepalive}) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code} ->
        IO.inspect code
        case code do
          200 -> {[{:ok, "Started pulling"}], {id, :keepalive}}
          404 -> {[{:error, "Repository does not exist or no read access"}], {id, :kill}}
          500 -> {[{:error, "Server error"}], {id, :kill}}
          _ -> {[{:error, "Server error"}], {id, :kill}}
        end
      %HTTPoison.AsyncHeaders{id: ^id, headers: _headers} ->
        {[], {id, :keepalive}}
      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
        IO.inspect chunk
        case Poison.decode(chunk) do
          {:ok, %{"status" => status}} ->
            {[{:pulling, status}], {id, :keepalive}}
          {:ok, %{"error" => error}} ->
            {[{:error, error}], {id, :kill}}
        end
      %HTTPoison.AsyncEnd{id: ^id} ->
        IO.puts "asyncEnd"
        {[{:end, "Finished pulling"}], {id, :kill}}
    end
  end

  @doc """
  Inspect a Docker image by name or id.
  """
  def inspect(name) do
    "#{@base_uri}/#{name}/json?all=true" 
    |> Docker.Client.get
    |> decode_inspect_response
  end

  defp decode_inspect_response(%HTTPoison.Response{body: body, status_code: status_code}) do
    Logger.debug "Decoding Docker API response: #{Kernel.inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          200 -> {:ok, dict}
          404 -> {:error, "No such image"}
          500 -> {:error, "Server error"}
          _ -> {:error, "Server error"}
        end
      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Deletes a local image.
  """
  def delete(image) do
    @base_uri <> "/" <> image 
    |> Docker.Client.delete
    |> decode_delete_response
  end

  defp decode_delete_response(%HTTPoison.Response{body: body, status_code: status_code}) do
    Logger.debug "Decoding Docker API response: #{Kernel.inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          200 -> {:ok, dict}
          404 -> {:error, "No such image"}
          409 -> {:error, "Conflict"}
          500 -> {:error, "Server error"}
          _ -> {:error, "Server error"}
        end
      {:error, message} ->
        {:error, message}
    end
  end
end
