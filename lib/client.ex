defmodule Docker.Client do
  @moduledoc """
  Wrapper module arround HTTP request.
  """

  require Logger

  defp base_url do
    host = Application.get_env(:docker, :host)
    version = Application.get_env(:docker, :version)
    "#{host}/#{version}"
  end

  defp default_headers, do: %{"Content-Type" => "application/json"}

  @doc """
  Send a GET request to the Docker API at the speicifed resource.
  """
  def get(resource, headers \\ default_headers()) do
    full = base_url() <> resource
    Logger.debug fn -> "Sending GET request to the Docker HTTP API: #{full}" end
    full
    |> HTTPoison.get!(headers, recv_timeout: :infinity)
  end

  @doc """
  Send a POST request to the Docker API, JSONifying the passed in data.
  """
  def post(resource, data \\ "", headers \\ default_headers()) do
    Logger.debug fn -> "Sending POST request to the Docker HTTP API: #{resource}, #{inspect data}" end
    data = Poison.encode! data
    Logger.debug fn -> "Posting #{inspect(base_url() <> resource)}" end
    base_url() <> resource
    |> HTTPoison.post!(data, headers, recv_timeout: :infinity)
  end

  @doc """
  Send a request with the verb to the Docker API, stream the response.
  """
  def stream(verb, resource, data \\ "", headers \\ default_headers()) do
    Logger.debug fn -> "Sending #{verb} request to the Docker HTTP API: #{resource}, #{inspect data}" end
    data = Poison.encode! data
    url = base_url() <> resource
    Logger.debug fn -> "Posting #{inspect(url)} #{inspect(headers)}" end
    HTTPoison.request!(verb, url, data, headers, [recv_timeout: :infinity, stream_to: self()])
  end

  @doc """
  Send a DELETE request to the Docker API.
  """
  def delete(resource, headers \\ default_headers()) do
    Logger.debug fn -> "Sending DELETE request to the Docker HTTP API: #{resource}" end
    base_url() <> resource
    |> HTTPoison.delete!(headers)
  end
end
