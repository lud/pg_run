defmodule PgRun do
  defmodule PgParams do
    @enforce_keys [:username, :password, :port, :database]
    defstruct @enforce_keys
  end

  def start_server(server) when is_atom(server) do
    server |> server_config() |> start_server()
  end

  def start_server(config) when is_list(config) do
    true = Keyword.keyword?(config)
    config |> Map.new() |> start_params() |> do_start()
  end

  # returns the server config from app configuration
  defp server_config(server) do
    app_config = Application.get_all_env(:pg_run)
    servers = Keyword.fetch!(app_config, :servers)
    _config = Keyword.fetch!(servers, server)
  end

  defp start_params(config) do
    %{platform: platform_params(config), pg: pg_params(config)}
  end

  defp pg_params(%{otp_app: app, ecto_repo: repo} = config) do
    ecto_params(app, repo, config[:show_invalid_params])
  end

  defp ecto_params(app, repo, show_invalid?) do
    case Application.fetch_env(app, repo) |> as_map() do
      {:ok, %{username: username, password: password, database: database, port: port}} ->
        %PgParams{username: username, password: password, database: database, port: port}

      {:ok, other} when show_invalid? ->
        raise "could not parse ecto params: #{inspect(other)}"

      {:ok, _other} ->
        raise "could not parse ecto params"

      :error ->
        raise "could not obain ecto params for repo #{repo} in OTP #{app}"
    end
  end

  defp platform_params(%{platform: :docker}) do
    {PgRun.Platform.Docker, []}
  end

  defp platform_params(%{platform: {:docker, opts}}) do
    {PgRun.Platform.Docker, opts}
  end

  defp platform_params(%{platform: other}) when is_atom(other) do
    {other, []}
  end

  defp platform_params(%{platform: {other, opts}}) when is_atom(other) do
    {other, opts}
  end

  defp platform_params(config) when not is_map_key(config, :platform) do
    platform_params(%{platform: :docker})
  end

  def do_start(%{platform: {mod, opts}, pg: pg} = params) do
    mod.start(pg, opts)
    # %{username: username, password: password, database: database, port: port}
  end

  defp as_map({:ok, list}) when is_list(list) do
    {:ok, Map.new(list)}
  end

  defp as_map(other) do
    other
  end
end
