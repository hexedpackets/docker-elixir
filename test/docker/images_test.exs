defmodule ImagesTest do
  use ExUnit.Case

  @test_image "busybox"
  @test_image_tag "latest"

  test "list images" do
    {:ok, images} = Docker.Images.list()
    assert is_list(images)
  end

  test "list images with filter" do
    {:ok, images} = Docker.Images.list("dangling=true")
    assert is_list(images)
  end

  test "pull image" do
    {:ok, _} = Docker.Images.pull(@test_image, @test_image_tag)
  end

  test "pull image and stream response" do
    stream = Docker.Images.stream_pull(@test_image, @test_image_tag)
    Enum.map(stream, fn elem -> send(self(), elem)  end)
    assert_receive {:ok, _}
    assert_receive {:pulling, _}
    assert_receive {:end, _}
  end

  test "auth and pull image" do
    {:ok, _} = Docker.Images.pull(@test_image, @test_image_tag, "username:password")
  end

  test "auth and pull image and stream response" do
    stream = Docker.Images.stream_pull(@test_image, @test_image_tag, "username:password")
    Enum.map(stream, fn elem -> send(self(), elem)  end)
    assert_receive {:ok, _}
    assert_receive {:pulling, _}
    assert_receive {:end, _}
  end

  test "inspect image" do
    {:ok, _} = Docker.Images.pull(@test_image, @test_image_tag)
    {:ok, _} = Docker.Images.inspect(@test_image)
  end

  test "delete image" do
    {:ok, _} = Docker.Images.pull(@test_image, @test_image_tag)
    {:ok, _} = Docker.Images.delete(@test_image)
  end
end
