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

  scope "/", ExpertAdviceWeb do
    pipe_through :browser

    get "/login", AuthController, :show
    post "/login", AuthController, :authenticate
    get "/register", AuthController, :new
    post "/register", AuthController, :create

    get "/", PageController, :index
    get "/:slug", PageController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExpertAdviceWeb do
  #   pipe_through :api
  # end
end
