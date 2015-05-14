defmodule CreateContainerConfigTest do
  use ExUnit.Case

  test "no hostname added" do
    conf = %Docker.Config{generic_hostname: true} |> Docker.Config.create_container
    assert is_nil(conf["Hostname"])
  end

  test "defined hostname is untouched" do
    hostname = "look-at-all-this-foo"
    conf = %Docker.Config{generic_hostname: false, hostname: hostname} |> Docker.Config.create_container
    assert conf["Hostname"] == hostname
  end

  test "environment variable formatting" do
    conf = %Docker.Config{environment: %{"FOO" => "bar"}} |> Docker.Config.create_container
    assert conf["Env"] == ["FOO=bar"]
  end

  test "exposed port formatting" do
    conf = %Docker.Config{ports: %{http: "4000:80"}} |> Docker.Config.create_container
    assert conf["ExposedPorts"] == %{"4000/tcp" => %{}}
  end

  test "volume formatting" do
    conf = %Docker.Config{volumes: %{"/opt/container" => "/data"}} |> Docker.Config.create_container
    assert conf["Volumes"] == %{"/data" => %{}}
  end
end
