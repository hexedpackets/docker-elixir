defmodule MiscTest do
  use ExUnit.Case

  @test_image "busybox"
  @test_image_tag "latest"

  setup_all do
    IO.puts "Pulling #{@test_image}:#{@test_image_tag} for testing..."
    Docker.Images.pull(@test_image, @test_image_tag)
    :ok
  end

  test "events stream" do
    %HTTPoison.AsyncResponse{id: id} = Docker.Misc.events_stream()
    conf = %{"AttachStdin" => false,
      "Env" => [],
      "Image" => "#{@test_image}:#{@test_image_tag}",
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }
    assert {:ok, container} = Docker.Containers.create(conf, "misc")
    assert_receive %HTTPoison.AsyncChunk{id: ^id, chunk: _}, :infinity
    Docker.Containers.remove(container["Id"])
  end
end
