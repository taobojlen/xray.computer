[
  import_deps: [:ecto, :phoenix, :surface],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  surface_inputs: ["lib/xray_web/**/*.ex"],
  subdirectories: ["priv/*/migrations"]
]
