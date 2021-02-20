ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Xray.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)

Mox.defmock(Xray.MockRegistry, for: Xray.Registry.Contract)
Mox.defmock(Xray.Api.MockNpm, for: [Xray.Api.StreamingApi.Contract, Xray.Api.CachedApi.Contract])
Mox.defmock(MockHTTPoison, for: HTTPoison.Base)
