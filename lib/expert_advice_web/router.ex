defmodule ExpertAdviceWeb.Router do
  use ExpertAdviceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug ExpertAdviceWeb.Auth.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", ExpertAdviceWeb do
    pipe_through [:browser, :auth]

    get "/login", AuthController, :show
    post "/login", AuthController, :authenticate
    get "/logout", AuthController, :logout
    get "/register", AuthController, :new
    post "/register", AuthController, :create

    get "/", PageController, :index

    scope "/" do
      pipe_through(:ensure_auth)

      get "/ask", PageController, :new
      post "/ask", PageController, :create
    end

    get "/:slug", PageController, :show
    post "/:slug/answer", PageController, :answer
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExpertAdviceWeb do
  #   pipe_through :api
  # end
end
