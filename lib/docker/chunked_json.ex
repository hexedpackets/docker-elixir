defmodule Docker.ChunkedJson do
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    with {:ok, env} <- Tesla.Middleware.JSON.encode(env, opts),
         {:ok, env} <- Tesla.run(env, next) do
      decode(env, opts)
    end
  end

  def decode(env, opts) do
    with true <- decodable?(env, opts),
         {:ok, body} <- decode_body(env, opts) do
      {:ok, %{env | body: body}}
    else
      false -> {:ok, env}
      error -> error
    end
  end

  defp decodable?(env, opts), do: decodable_body?(env) && decodable_content_type?(env, opts)

  defp decodable_body?(env) do
    (is_binary(env.body) && env.body != "") || (is_list(env.body) && env.body != [])
  end

  defp decodable_content_type?(env, _opts) do
    case Tesla.get_header(env, "content-type") do
      "application/json" -> true
      _ -> false
    end
  end

  defp decode_body(env, _opts) do
    case Tesla.get_header(env, "transfer-encoding") do
      "chunked" ->
        # possible not real JSON, ignore errors
        case Jason.decode(env.body) do
          {:ok, body} -> {:ok, body}
          _ -> {:ok, env.body}
        end
      _ -> Jason.decode(env.body)
    end
  end
end
