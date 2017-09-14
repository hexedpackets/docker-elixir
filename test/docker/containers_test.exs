defmodule ContainersTest do
  use ExUnit.Case

  @test_image "busybox"
  @test_image_tag "latest"
  @test_conf %{"AttachStdin" => false,
      "Env" => [],
      "Image" => "#{@test_image}:#{@test_image_tag}",
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }

  setup_all do
    IO.puts "Pulling #{@test_image}:#{@test_image_tag} for testing..."
    Docker.Images.pull(@test_image, @test_image_tag)
    :ok
  end

  test "create and remove minimal container" do
    assert {:ok, %{"Id" => id}} = Docker.Containers.create(@test_conf)
    assert {:ok} = Docker.Containers.remove(id)
  end

  test "cannot create two container with the same name" do
    assert {:ok, %{"Id" => id}} = Docker.Containers.create(@test_conf, "coco")
    assert {:error, _} = Docker.Containers.create(@test_conf, "coco")
    assert {:ok} = Docker.Containers.remove(id)
  end

  test "list" do
    {:ok, containers} = Docker.Containers.list()
    assert is_list(containers)
  end

  test "inspect" do
    assert {:ok, %{"Id" => id}} = Docker.Containers.create(@test_conf)
    assert {:ok, %{"Id" => ^id}} = Docker.Containers.inspect(id)
    assert {:ok} = Docker.Containers.remove(id)
  end

  test "start and stop" do
    conf = %{"AttachStdin" => false,
      "Env" => [],
      "Image" => "redis:latest",
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }
    Docker.Images.pull("redis", "latest")
    assert {:ok, %{"Id" => id}} = Docker.Containers.create(conf)
    assert {:ok} = Docker.Containers.start(id)
    assert {:ok} = Docker.Containers.stop(id)
    assert {:ok} = Docker.Containers.remove(id)
  end

  test "start and kill" do
    conf = %{"AttachStdin" => false,
      "Env" => [],
      "Image" => "redis:latest",
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }
    Docker.Images.pull("redis", "latest")
    assert {:ok, %{"Id" => id}} = Docker.Containers.create(conf)
    assert {:ok} = Docker.Containers.start(id)
    assert {:ok} = Docker.Containers.kill(id)
    assert {:ok} = Docker.Containers.remove(id)
  end


  test "restart" do
    conf = %{"AttachStdin" => false,
      "Env" => [],
      "Image" => "redis:latest",
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }
    Docker.Images.pull("redis", "latest")
    assert {:ok, %{"Id" => id}} = Docker.Containers.create(conf)
    assert {:ok} = Docker.Containers.start(id)
    assert {:ok} = Docker.Containers.stop(id)
    assert {:ok} = Docker.Containers.restart(id)
    assert {:ok} = Docker.Containers.stop(id)
    assert {:ok} = Docker.Containers.remove(id)
  end
end
