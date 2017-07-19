defmodule ClientTest do
  use ExUnit.Case

  test "info" do
    assert {:ok, _} = Docker.Misc.info()
  end

  test "version" do
    assert {:ok, %{"ApiVersion" => _, "Version" => _}} = Docker.Misc.version()
  end

  test "ping" do
    assert {:ok, _} = Docker.Misc.ping()
  end
end
