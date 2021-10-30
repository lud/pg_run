defmodule PgRun.Test.Repo do
  use Ecto.Repo,
    otp_app: :pg_run,
    adapter: Ecto.Adapters.Postgres
end
