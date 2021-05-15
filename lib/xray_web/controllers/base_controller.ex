defmodule XrayWeb.BaseController do
  use XrayWeb, :controller

  def show(conn, _params) do
    redirect(conn, to: "/source")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end
end
