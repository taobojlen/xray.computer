ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Xray.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)

Hammox.defmock(Xray.MockRegistry, for: Xray.Registry.Contract)

Hammox.defmock(Xray.Api.MockNpm,
  for: [Xray.Api.StreamingApi.Contract, Xray.Api.CachedJsonApi.Contract]
)

Hammox.defmock(MockHTTPoison, for: HTTPoison.Base)

Hammox.defmock(Xray.Storage.MockS3, for: Xray.Storage.Repo)
