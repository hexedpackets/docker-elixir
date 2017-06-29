defmodule Docker.Client do
  require Logger

  defp base_url do
    host = Application.get_env(:docker, :host)
    version = Application.get_env(:docker, :version)
    "#{host}/#{version}"
  end

  @default_headers %{"Content-Type" => "application/json"}

  @doc """
  Send a GET request to the Docker API at the speicifed resource.
  """
  def get(resource, headers \\ @default_headers) do
    full = base_url() <> resource
    Logger.debug "Sending GET request to the Docker HTTP API: #{full}"
    full
    |> HTTPoison.get!(headers, recv_timeout: :infinity)
    |> decode_body
  end

  @doc """
  Send a POST request to the Docker API, JSONifying the passed in data.
  """
  def post(resource, data \\ "", headers \\ @default_headers) do
    Logger.debug "Sending POST request to the Docker HTTP API: #{resource}, #{inspect data}"
    data = Poison.encode! data
    Logger.debug("Posting #{inspect(base_url() <> resource)}")
    base_url() <> resource
    |> HTTPoison.post!(data, headers, recv_timeout: :infinity)
    |> decode_body
  end

  @doc """
  Send a POST request to the Docker API, stream the response.
  """
  def stream(verb, resource, data \\ "", headers \\ @default_headers) do
    Logger.debug "Sending POST request to the Docker HTTP API: #{resource}, #{inspect data}"
    data = Poison.encode! data
    url = base_url() <> resource
    Logger.debug("Posting #{inspect(url)}")
    HTTPoison.request!(verb, url, data, headers, [recv_timeout: :infinity, stream_to: self()])
  end

  @doc """
  Send a DELETE request to the Docker API.
  """
  def delete(resource, headers \\ @default_headers) do
    Logger.debug "Sending DELETE request to the Docker HTTP API: #{resource}"
    base_url() <> resource
    |> HTTPoison.delete!(headers)
  end

  defp decode_body(%HTTPoison.Response{body: "", status_code: status_code}) do
    Logger.debug "Empty response"
    case status_code do
      x when x < 400 ->
        {:ok}
      _ ->
        {:error}
    end
  end

  defp decode_body(%HTTPoison.Response{body: body, status_code: status_code}) do
    Logger.debug "Decoding Docker API response: #{inspect body}"
    case Poison.decode(body) do
      {:ok, dict} ->
        case status_code do
          x when x < 400 ->
            {:ok, dict}
          _ ->
            {:error, dict}
        end
      _ ->
        {:error, "Unknow errors."}
    end
  end
end
