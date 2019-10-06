defmodule ExpertAdviceWeb.AuthController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Identity
  alias ExpertAdviceWeb.Auth.Guardian
  alias ExpertAdviceWeb.Schemas.Identity.Register, as: RegisterSchema
  alias ExpertAdviceWeb.Schemas.Identity.Login, as: LoginSchema

  @registration_success "Successfully registered. You can now login with your created credentials."
  @registration_fail "Error while registering - check the invalid fields and try again"
  @login_success "Successfully logged in"
  @login_fail "Invalid username or password"

  def new(conn, _params) do
    changeset = RegisterSchema.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    params["register"]
    |> RegisterSchema.changeset()
    |> do_create(conn)
  end

  defp do_create(%{valid?: true} = schema, conn) do
    case Identity.register(schema.changes) do
      :ok ->
        conn
        |> put_flash(:info, @registration_success)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset} ->
        new_changeset = RegisterSchema.merge_with_changeset(schema, changeset)

        conn
        |> put_flash(:error, @registration_fail)
        |> render("new.html", changeset: new_changeset)
    end
  end

  defp do_create(changeset, conn) do
    conn
    |> put_flash(:error, @registration_fail)
    |> render("new.html", changeset: Map.put(changeset, :action, :insert))
  end

  def show(conn, _params) do
    changeset = LoginSchema.changeset()
    render(conn, "show.html", changeset: changeset)
  end

  def authenticate(conn, params) do
    params["login"]
    |> LoginSchema.changeset()
    |> do_authenticate(conn)
  end

  defp do_authenticate(%{valid?: true} = schema, conn) do
    username = schema.changes.username
    password = schema.changes.password

    case Identity.authenticate(username, password) do
      {:ok, account} ->
        conn
        |> put_flash(:info, @login_success)
        |> Guardian.Plug.sign_in(account)
        |> redirect(to: "/")

      {:error, _} ->
        conn
        |> put_flash(:error, @login_fail)
        |> render("show.html", changeset: schema)
    end
  end

  defp do_authenticate(changeset, conn) do
    render(conn, "show.html", changeset: Map.put(changeset, :action, :insert))
  end

  def logout(conn, _params) do
    [referer | _] = get_req_header(conn, "referer")

    conn
    |> Guardian.Plug.sign_out()
    |> redirect(external: referer)
  end
end
