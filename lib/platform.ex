defmodule PgRun.Platform do
  @callback start(%PgRun.PgParams{}, opts :: Keyword.t()) :: :ok
end
