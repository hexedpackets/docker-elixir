defmodule Docker.Images do
  # require Logger

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
    # Logger.debug "Decoding Docker API response: #{inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          200 -> {:ok, dict}
          500 -> {:error, "Server error"}
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
    Docker.Client.stream(:post, url)
    handle_pull()
  end

  @doc """
  Pull a Docker image from the repo after authenticating.
  """
  def pull(image, tag, auth) do
    auth_header = auth |> Poison.encode! |> Base.encode64
    headers = %{
      "X-Registry-Auth" => auth_header,
      "Content-Type" => "application/json"
    }

    url = "#{@base_uri}/create?fromImage=#{image}&tag=#{tag}"
    Docker.Client.stream(:post, url, headers)
    handle_pull()
  end

  defp handle_pull do
    receive do
      %HTTPoison.AsyncStatus{id: _id, code: code} ->
        case code do
          200 -> handle_pull()
          404 -> {:error, "Repository does not exist or no read access"}
          500 -> {:error, "Server error"}
        end
      %HTTPoison.AsyncHeaders{id: _id, headers: _headers} ->
        handle_pull()
      %HTTPoison.AsyncChunk{id: _id, chunk: _chunk} ->
        handle_pull()
      %HTTPoison.AsyncEnd{id: _id} ->
        {:ok, "Image successfully pulled"}
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
    # Logger.debug "Decoding Docker API response: #{inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          200 -> {:ok, dict}
          404 -> {:error, "No such image"}
          500 -> {:error, "Server error"}
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
    # Logger.debug "Decoding Docker API response: #{inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          200 -> {:ok, dict}
          404 -> {:error, "No such image"}
          409 -> {:error, "Conflict"}
          500 -> {:error, "Server error"}
        end
      {:error, message} ->
        {:error, message}
    end
  end
end
