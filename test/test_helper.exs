ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Xray.Repo, :manual)
Mox.defmock(Xray.MockRegistry, for: Xray.Registry.Behaviour)
