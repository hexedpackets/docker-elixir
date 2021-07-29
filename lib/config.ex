defmodule Docker.Config do
  defstruct name: nil,
            image: nil,
            command: "",
            entrypoint: "",
            ports: %{},   # %{name: "container_port:host_port"}
            volumes: %{}, # %{host_mount: container_mount}
            remove: false,
            environment: %{},
            user: "",
            working_dir: "",
            hostname: nil,
            generic_hostname: false,
            host_config: %{"network_mode" => "bridge"}

  @doc """
  Given a %Docker.Config{} struct, formats and returns a dictionary of the appropiate options
  for creating a container.
  """
  def create_container(conf = %Docker.Config{generic_hostname: nil}) do
    %Docker.Config{conf | generic_hostname: false} |> create_container
  end
  def create_container(conf = %Docker.Config{generic_hostname: false}) do
    {:ok, os_hostname} = :inet.gethostname
    hostname = conf.hostname || "#{conf.name}-#{os_hostname}"
    conf
        |> Map.put(:hostname, hostname)
        |> Map.delete(:generic_hostname)
        |> create_container
  end
  def create_container(conf = %Docker.Config{}) do
    %{"Hostname" => conf.hostname,
      "User" => conf.user,
      "Entrypoint" => conf.entrypoint,
      "AttachStdin" => conf.remove,
      "Env" => format_environment(conf.environment),
      "Cmd" => conf.command |> OptionParser.split,
      "Image" => conf.image,
      "Volumes" => map_empty_dict(conf.volumes, 1),
      "WorkingDir" => conf.working_dir,
      "ExposedPorts" => format_ports(conf.ports),
      "NetworkDisabled" => Map.get(conf.host_config, "network_mode") == "none",
      "HostConfig" => format_host_config(conf.host_config),
    }
  end

  @doc """
  Given a %Docker.Config{} struct, formats and returns a dictionary of the appropriate
  options for starting a container.
  """
  def start_container(conf = %Docker.Config{ports: %{}}) do
    port_map = conf.ports
        |> Map.values
        |> Enum.map(&port_to_tuple/1)
        |> Enum.map(&({elem(&1, 0), [%{"HostPort" => elem(&1, 1)}]}))
        |> Enum.into(%{})

    %{"Binds" => format_volumes(conf.volumes),
      "PortBindings" => port_map,
      "NetworkMode" => Map.get(conf.host_config, "network_mode", "bridge"),
    }
  end
  def start_container(conf = %Docker.Config{}) do
    %{"Binds" => format_volumes(conf.volumes)}
  end

  def format_environment(nil), do: []
  def format_environment(env = %{}) do
    Enum.map(env, &(elem(&1, 0) <> "=" <> elem(&1, 1)))
  end

  def format_ports(nil), do: %{}
  def format_ports(ports = %{}) do
    ports
        |> Map.values
        |> Enum.map(&port_to_tuple/1)
        |> map_empty_dict(0)
  end

  def format_volumes(nil), do: nil
  def format_volumes(volumes = %{}) do
    volumes |> Enum.map(&(to_string(elem(&1, 0)) <> ":" <> elem(&1, 1)))
  end

  def format_host_config(nil), do: %{}
  def format_host_config(host_config) do
    host_config
    |> Enum.map(fn({key, value}) -> {titlecase(key), value} end)
    |> Enum.into(%{})
  end


  @doc """
  Takes a port string, either a single port or : deliminated pair,
  and turns it into a two-element tuple.
  """
  def port_to_tuple(port) when is_binary(port) do
    port |> String.split(":") |> port_to_tuple
  end
  def port_to_tuple([container_port, host_port]) do
    {port_protocol(container_port), host_port}
  end
  def port_to_tuple([port]) do
    host_port = port |> String.split("/") |> List.first
    {port_protocol(port), host_port}
  end

  defp port_protocol([port, protocol]), do: port <> "/" <> protocol
  defp port_protocol([port]), do: port <> "/tcp"
  defp port_protocol(port), do: String.split(port, "/") |> port_protocol

  defp map_empty_dict(nil, _), do: %{}
  defp map_empty_dict(dict, element) do
    Enum.map(dict, &({elem(&1, element), %{}})) |> Enum.into(%{})
  end

  defp titlecase(value) when is_atom(value), do: value |> to_string |> titlecase
  defp titlecase(value) when is_binary(value), do: value |> String.split("_") |> titlecase
  defp titlecase(words) when is_list(words) do
    words
    |> Enum.map(&String.capitalize/1)
    |> Enum.join
  end
end
