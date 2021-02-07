ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Diff.Repo, :manual)
Mox.defmock(Diff.MockRegistry, for: Diff.Registry.Behaviour)
