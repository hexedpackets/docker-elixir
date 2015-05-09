defmodule ContainersTest do
  use ExUnit.Case

  @test_image "busybox"
  @test_image_tag "latest"

  setup_all do
    IO.puts "Pulling #{@test_image}:#{@test_image_tag} for testing..."
    Docker.Images.pull(@test_image, @test_image_tag)
    :ok
  end

  test "create minimal container" do
    conf = %{"AttachStdin" => false,
      "Env" => %{},
      "Image" => "#{@test_image}:#{@test_image_tag}",
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }
    assert Docker.Containers.create(conf)
  end
end
