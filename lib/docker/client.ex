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
    full = base_url <> resource
    Logger.debug "Sending GET request to the Docker HTTP API: #{full}"
    full
    |> HTTPoison.get!(headers)
    |> decode_body
  end

  @doc """
  Send a POST request to the Docker API, JSONifying the passed in data.
  """
  def post(resource, data \\ "", headers \\ @default_headers) do
    Logger.debug "Sending POST request to the Docker HTTP API: #{resource}, #{inspect data}"
    data = Poison.encode! data
    Logger.debug data
    base_url <> resource
    |> HTTPoison.post!(data, headers)
    |> decode_body
  end

  @doc """
  Send a DELETE request to the Docker API.
  """
  def delete(resource, headers \\ @default_headers) do
    Logger.debug "Sending DELETE request to the Docker HTTP API: #{resource}"
    base_url <> resource
    |> HTTPoison.delete!(headers)
  end

  defp decode_body(%HTTPoison.Response{body: ""}) do
    Logger.debug "Empty response"
    :nil
  end
  defp decode_body(%HTTPoison.Response{body: body, status_code: status_code}) do
    Logger.debug "Decoding Docker API response: #{inspect body}"
    with {:ok, dict} <- Poison.decode(body),
      true <- status_code < 300 do
        {:ok, dict}
    else
      {:error, body} ->
        {:error, body}
      _ ->
      {:error, "Unknow errors."}
    end
  end
end
