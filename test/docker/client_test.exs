defmodule ClientTest do
  use ExUnit.Case

  test "client get url" do
    %HTTPoison.Response{body: _, status_code: status_code} = Docker.Client.get "/info"
    assert status_code == 200
  end

  test "client post url" do
    %HTTPoison.Response{body: _, status_code: status_code} = Docker.Client.post "/images/create?fromImage=redis&tag=latest"
    assert status_code == 200
  end

  test "client stream url" do
    assert %HTTPoison.AsyncResponse{id: id} = Docker.Client.stream(:post, "/images/create?fromImage=redis&tag=latest")
    assert_receive %HTTPoison.AsyncStatus{id: ^id, code: 200}, :infinity
    assert_receive %HTTPoison.AsyncHeaders{id: ^id, headers: _}, :infinity
    assert_receive %HTTPoison.AsyncChunk{id: ^id, chunk: _}, :infinity
    assert_receive %HTTPoison.AsyncEnd{id: ^id}, :infinity
  end

end
