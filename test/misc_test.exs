defmodule MiscTest do
  use ExUnit.Case
  # New tests for Docker.Misc is in test/docker/misc_test.exs

  @test_image "busybox"
  @test_image_tag "latest"

  setup_all do
    IO.puts "Pulling #{@test_image}:#{@test_image_tag} for testing..."
    Docker.Images.pull(@test_image, @test_image_tag)
    :ok
  end

  # This is the test for the legacy Docker.Misc.events_stream/0 function
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
