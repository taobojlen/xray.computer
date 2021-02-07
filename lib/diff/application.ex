defmodule Diff.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    setup_tmp_dir()

    children = [
      # Start the Ecto repository
      Diff.Repo,
      # Start the Telemetry supervisor
      DiffWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Diff.PubSub},
      # Start the Endpoint (http/https)
      DiffWeb.Endpoint,
      # Start queuing system
      {Oban, oban_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Diff.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DiffWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.get_env(:diff, Oban)
  end

  defp setup_tmp_dir() do
    if dir = Application.get_env(:diff, :tmp_dir) do
      File.mkdir_p!(dir)
      Application.put_env(:diff, :tmp_dir, Path.expand(dir))
    end
  end
end
