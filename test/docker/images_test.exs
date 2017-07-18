defmodule ImagesTest do
  use ExUnit.Case

  @test_repository "bitnami"
  @test_image "redis"
  @test_image_tag "latest"

  test "list" do
    {:ok, images} = Docker.Images.list()
    assert is_list(images)
  end

  test "list with filter" do
    {:ok, images} = Docker.Images.list("dangling=true")
    assert is_list(images)
  end

  test "pull" do
    {:ok, _} = Docker.Images.pull("#{@test_repository}/#{@test_image}", @test_image_tag)
  end

  test "auth and pull" do
    {:ok, _} = Docker.Images.pull("#{@test_repository}/#{@test_image}", @test_image_tag, "username:password")
  end

  test "inspect" do
    {:ok, _} = Docker.Images.pull("#{@test_repository}/#{@test_image}", @test_image_tag)
    {:ok, _} = Docker.Images.inspect("#{@test_repository}/#{@test_image}")
  end

  test "delete" do
    {:ok, _} = Docker.Images.pull("#{@test_repository}/#{@test_image}", @test_image_tag)
    {:ok, _} = Docker.Images.delete(@test_image)
  end
end
