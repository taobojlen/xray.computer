defmodule Diff.Repo do
  use Ecto.Repo,
    otp_app: :diff,
    adapter: Ecto.Adapters.Postgres
end
