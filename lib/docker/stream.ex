defmodule Docker.Stream do
  @test_image "redis"
  @test_image_tag "latest"

  def test do

    conf = %{"AttachStdin" => false,
      "Env" => [],
      "Image" => "#{@test_image}:#{@test_image_tag}",
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }
    %HTTPoison.AsyncResponse{id: id} = Docker.Misc.events_stream()
    #%HTTPoison.AsyncResponse{id: id} = Docker.Images.pull_stream("marcelocg/phoenix")

    collect_response(id, self, [])

    IO.puts "async?"
  end
  

  def collect_response(id, par, data) do
    IO.puts "collect"
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code} ->
        IO.puts code
        collect_response(id, par, data)
      %HTTPoison.AsyncHeaders{id: ^id, headers: headers} ->
        IO.inspect headers
        collect_response(id, par, data)
      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
        IO.inspect Poison.decode! chunk
        collect_response(id, par, data ++ [chunk])
      %HTTPoison.AsyncEnd{id: ^id} ->
        IO.inspect data
    end
  end

end
