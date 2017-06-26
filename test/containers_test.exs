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
      "Env" => [],
      "Image" => "#{@test_image}:#{@test_image_tag}",
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }
    assert {:ok, _} = Docker.Containers.create(conf)
  end

  test "Try to create two container with the same name" do
    conf = %{"AttachStdin" => false,
      "Env" => [],
      "Image" => "#{@test_image}:#{@test_image_tag}",
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }
    assert {:ok, container} = Docker.Containers.create(conf, "coco")
    assert {:error, _} = Docker.Containers.create(conf, "coco")
    Docker.Containers.remove(container["Id"])
  end

end
