import Config

config :pg_run, PgRun.Test.Repo,
  username: "pgrun_test",
  password: "pgrun_test",
  database: "pgrun_test",
  hostname: "localhost",
  port: 8807,
  pool_size: 10

config :pg_run,
  servers: [
    test_1: [ecto_repo: PgRun.Test.Repo, otp_app: :pg_run, show_invalid_params: true]
  ]
