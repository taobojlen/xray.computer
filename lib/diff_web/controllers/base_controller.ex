defmodule DiffWeb.BaseController do
  use DiffWeb, :controller

  def show(conn, _params) do
    redirect(conn, to: "/diff")
  end
end
