defmodule PgRun.Platform.Docker do
  @defaults [
    image: "postgres",
    tag: "latest",
    name: "pg_run_postgres"
  ]

  @spec start(%PgRun.PgParams{}, opts :: Keyword.t()) :: :ok
  def start(%PgRun.PgParams{} = params, opts) do
    opts = default_opts(opts)
    env = build_env(params)
    ports = [{to_string(params.port), "5432"}]

    compose_path = Path.join(tmp_dir!(), "docker-compose.yml")

    write_compose(compose_path, opts[:image], opts[:tag], opts[:name], env, ports)

    case DockerCompose.up(compose_path: compose_path) do
      {:ok, output} ->
        IO.puts(:stderr, output)
        :ok

      {:error, code, output} ->
        IO.puts(:stderr, output)
        {:error, code}
    end
  end

  defp default_opts(opts) do
    Keyword.merge(@defaults, opts)
  end

  defp build_env(%PgRun.PgParams{username: username, password: password, database: database}) do
    %{"POSTGRES_USER" => username, "POSTGRES_DB" => database, "POSTGRES_PASSWORD" => password}
  end

  # defp docker_run(image, tag, name, env, ports) do
  #   command = "docker"

  #   args =
  #     ["run", "--name", name] ++
  #       cli_kvs(env, "--env", "=") ++ cli_kvs(ports, "--publish", ":") ++ ["#{image}:#{tag}"]

  #   [command, " ", args |> Enum.intersperse(" ")]
  #   |> IO.puts()
  # end

  # defp cli_kvs(enum, prefix, sep) do
  #   Enum.flat_map(enum, fn {key, value} -> [prefix, "#{key}#{sep}#{value}"] end)
  # end

  defp tmp_dir!() do
    cwd = File.cwd!()

    case System.tmp_dir!() do
      ^cwd ->
        raise "could not obtain a temporary directory to write the compose file"

      other ->
        dir = "#{other}/pg_run_compose"
        File.mkdir_p!(dir)
        dir
    end
  end

  defp write_compose(path, image, tag, name, env, ports) do
    yaml = """
    version: '3.6'
    services:
      #{name}:
        environment: #{env_map(env)}
        image: '#{image}:#{tag}'
        restart: unless-stopped
        ports: #{ports_map(ports)}
    """

    IO.puts(yaml)
    File.write!(path, yaml)
  end

  defp env_map(env) do
    pairs =
      env
      |> Enum.map(fn {k, v} -> [inspect(k), ?:, inspect(v)] end)
      |> Enum.intersperse(?,)

    [?{, pairs, ?}]
  end

  defp ports_map(ports) do
    pairs =
      ports
      |> Enum.map(fn {k, v} -> inspect("#{k}:#{v}") end)
      |> Enum.intersperse(?,)

    [?[, pairs, ?]]
  end
end
