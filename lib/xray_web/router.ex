defmodule XrayWeb.Router do
  use XrayWeb, :router
  use Honeybadger.Plug
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {XrayWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :admin do
    plug :browser
    plug :auth

    defp auth(conn, _opts) do
      Plug.BasicAuth.basic_auth(conn, Application.get_env(:xray, :basic_auth))
    end
  end

  scope "/", XrayWeb do
    pipe_through(:browser)

    get("/", BaseController, :show)
    live("/about", AboutLive, :index)

    live_session :diff do
      live("/diff", SelectDiffLive, :index)
      live("/diff/:registry/:package/:version_from/:version_to", ViewDiffLive, :index)
    end

    live_session :source do
      live("/source", SelectSourceLive, :index)
      live("/source/:registry/:package/:version", ViewSourceLive, :index)
      live("/source/:registry/:package/:version/:filename", ViewSourceLive, :index)
    end
  end

  scope "/" do
    dashboard_pipeline = if Application.get_env(:xray, :env) == :dev, do: :browser, else: :admin
    pipe_through(dashboard_pipeline)
    live_dashboard("/dashboard", metrics: XrayWeb.Telemetry, ecto_repos: [Xray.Repo])
  end
end
