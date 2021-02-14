ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Xray.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)

Mox.defmock(Xray.MockRegistry, for: Xray.Registry.Behaviour)
Mox.defmock(Xray.Api.MockNpm, for: [Xray.Api.StreamingApi, HTTPoison.Base])
