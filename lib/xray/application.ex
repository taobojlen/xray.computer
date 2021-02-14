defmodule Xray.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    setup_tmp_dir()

    children = [
      # Start the Ecto repository
      Xray.Repo,
      # Start the Telemetry supervisor
      XrayWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Xray.PubSub},
      # Start the Endpoint (http/https)
      XrayWeb.Endpoint,
      # Start queuing system
      {Oban, oban_config()},
      # Start scheduler
      Xray.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Xray.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    XrayWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.get_env(:xray, Oban)
  end

  defp setup_tmp_dir do
    if dir = Application.get_env(:xray, :tmp_dir) do
      File.mkdir_p!(dir)
      Application.put_env(:xray, :tmp_dir, Path.expand(dir))
    end
  end
end
