defmodule ExpertAdviceWeb.Auth.ErrorHandler do
  @moduledoc """
  The error handler module for handling invalid authentications.
  """
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> put_flash(:error, "You must be logged in to do this!")
    |> redirect(to: "/")
  end
end
