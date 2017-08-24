defmodule Docker.Images do
  require Logger

  @base_uri ""

  @doc """
  Get logs from a running Docker container.
  """
  def log(container_id, opts \\ %{})
  def log(container_id, opts) do
    url = "#{@base_uri}/containers/#{container_id}/logs?follow=true"
    %HTTPoison.AsyncResponse{id: id} = Docker.Client.stream(:get, url)
    handle_log(id)
  end


  defp handle_log(id) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code} ->
        case code do
          200 -> handle_log(id)
          404 -> {:error, "Repository does not exist or no read access"}
          500 -> {:error, "Server error"}
          _ -> {:error, "Server error"}
        end
      %HTTPoison.AsyncHeaders{id: ^id, headers: _headers} ->
        handle_log(id)
      %HTTPoison.AsyncChunk{id: ^id, chunk: _chunk} ->
        handle_log(id)
      %HTTPoison.AsyncEnd{id: ^id} ->
        {:ok, "Image successfully loged"}
      other ->
        Logger.info("How i'm suppose to handle this ?: #{Kernel.inspect(other)}")
    end
  end

  @doc """
  Log a Docker container_id and return the response in a stream.
  """
  def stream_log(container_id), do: stream_log(container_id, %{})
  def stream_log(container_id, opts) do
    stream = Stream.resource(
      fn -> start_log("#{@base_uri}/containers/#{container_id}/logs?follow=true") end,
      fn({id, status}) -> receive_log({id, status}) end,
      fn _ -> nil end
    )
    stream
  end

  defp start_log(url) do
    %HTTPoison.AsyncResponse{id: id} = Docker.Client.stream(:get, url)
    {id, :keepalive}
  end

  defp start_log(url, headers) do
    %HTTPoison.AsyncResponse{id: id} = Docker.Client.stream(:get, url, "", headers)
    {id, :keepalive}
  end

  defp receive_log({_id, :kill}) do
    {:halt, nil}
  end
  defp receive_log({id, :keepalive}) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code} ->
        IO.inspect code
        case code do
          200 -> {[{:ok, "Started loging"}], {id, :keepalive}}
          404 -> {[{:error, "Repository does not exist or no read access"}], {id, :kill}}
          500 -> {[{:error, "Server error"}], {id, :kill}}
          _ -> {[{:error, "Server error"}], {id, :kill}}
        end
      %HTTPoison.AsyncHeaders{id: ^id, headers: _headers} ->
        {[], {id, :keepalive}}
      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
        IO.inspect chunk

        # Handle the case of multiple chunks in one
        last_chunk = chunk
          |> String.split(~r/\n/)
          |> Enum.filter(&(String.length(&1) > 0))
          |> Enum.map(fn (r) -> Poison.decode(r) end)
          |> List.last

        case last_chunk do
          {:ok, %{"status" => status}} ->
            {[{:loging, status}], {id, :keepalive}}
          {:ok, %{"error" => error}} ->
            {[{:error, error}], {id, :kill}}
          others ->
            IO.puts "WTF ? No matching case for"
            IO.inspect(others)
            IO.puts("????")
            {[{:error, "no idea"}], {id, :kill}}
        end
      %HTTPoison.AsyncEnd{id: ^id} ->
        IO.puts "asyncEnd"
        {[{:end, "Finished loging"}], {id, :kill}}
    end
  end

end
