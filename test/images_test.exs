defmodule ImagesTest do
  use ExUnit.Case

  @test_image "bitnami/redis"
  @test_image_tag "latest"

  setup_all do
    IO.puts "Pulling #{@test_image}:#{@test_image_tag} for testing..."
    Docker.Images.pull(@test_image, @test_image_tag)
    :ok
  end

  test "list images" do
    {:ok, images} = Docker.Images.list()
    assert is_list(images)
  end

  test "inspect image" do
    assert {:ok , _} = Docker.Images.inspect(@test_image)
  end

  test "streaming pulling" do
    Docker.Images.delete(@test_image)
    assert %HTTPoison.AsyncResponse{id: id} =
      Docker.Images.pull_stream(@test_image)
    assert_receive %HTTPoison.AsyncStatus{id: id, code: 200}, :infinity
    assert_receive %HTTPoison.AsyncHeaders{id: id, headers: _}, :infinity
    assert_receive %HTTPoison.AsyncChunk{id: id, chunk: _}, :infinity
    assert_receive %HTTPoison.AsyncEnd{id: id}, :infinity
  end
end
