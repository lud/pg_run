defmodule PgRunTest do
  use ExUnit.Case
  doctest PgRun

  test "postgres/docker can be started from app config" do
    assert :ok = PgRun.start_server(:test_1)
    IO.puts("sleep 1000")
    Process.sleep(1000)
    pid = start_supervised!(PgRun.Test.Repo)

    assert %Postgrex.Result{command: :select, num_rows: 1, rows: [[1]]} =
             PgRun.Test.Repo.query!("select 1")
  end
end
