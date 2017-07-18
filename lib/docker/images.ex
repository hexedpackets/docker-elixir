defmodule Docker.Images do
  # require Logger

  @base_uri "/images"

  @doc """
  List all Docker images.
  """
  def list do
    "#{@base_uri}/json?all=true" 
    |> Docker.Client.get
    |> decode_response
  end

  @doc """
  Return a filtered list of Docker images.
  """
  def list(filter) do
    "#{@base_uri}/json?filter=#{filter}" 
    |> Docker.Client.get
    |> decode_response
  end

  @doc """
  Inspect a Docker image by name or id.
  """
  def inspect(name) do
    "#{@base_uri}/#{name}/json?all=true" |> Docker.Client.get
  end

  @doc """
  Pull a Docker image from the repo.
  """
  def pull(image), do: pull(image, "latest")
  def pull(image, tag) do
    "#{@base_uri}/create?fromImage=#{image}&tag=#{tag}"
    |> Docker.Client.post
    |> decode_response
  end

  @doc """
  Pull a Docker image as stream.
  """
  def pull_stream(image), do: pull_stream(image, "latest")
  def pull_stream(image, tag) do
    url = "#{@base_uri}/create?fromImage=#{image}&tag=#{tag}"
    Docker.Client.stream(:post, url)
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

    "#{@base_uri}/create?fromImage=#{image}&tag=#{tag}"
    |> Docker.Client.post("", headers)
  end

  @doc """
  Deletes a local image.
  """
  def delete(image) do
    @base_uri <> "/" <> image |> Docker.Client.delete
  end

  # defp decode_response(%HTTPoison.Response{body: "", status_code: status_code}) do
  #   # Logger.debug "Empty response"
  #   case status_code do
  #     x when x < 400 ->
  #       {:ok}
  #     _ ->
  #       {:error}
  #   end
  # end

  defp decode_response(%HTTPoison.Response{body: body, status_code: status_code}) do
    # Logger.debug "Decoding Docker API response: #{inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          200 ->
            {:ok, dict}
          # x when x < 400 ->
          #   {:ok, dict}
          _ ->
            {:error, dict}
        end
      {:error, message} ->
        {:error, message}
    end
  end
end
