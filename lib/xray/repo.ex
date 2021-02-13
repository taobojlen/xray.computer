defmodule Xray.Repo do
  use Ecto.Repo,
    otp_app: :xray,
    adapter: Ecto.Adapters.Postgres
end
