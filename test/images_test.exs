defmodule ImagesTest do
  use ExUnit.Case

  @test_image "busybox"
  @test_image_tag "latest"

  setup_all do
    IO.puts "Pulling #{@test_image}:#{@test_image_tag} for testing..."
    Docker.Images.pull(@test_image, @test_image_tag)
    :ok
  end

  test "list images" do
    images = Docker.Images.list()
    assert is_list(images)
    filtered = Enum.filter(images, fn image ->
      "#{@test_image}:#{@test_image_tag}" in image["RepoTags"]
    end)
    assert length(filtered) > 0
  end

  test "inspect image" do
    image = Docker.Images.inspect(@test_image)
    assert image
  end
end
