defmodule ContentoWeb.Router do
  use ContentoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ContentoWeb.Plug.Settings
  end

  pipeline :contento do
    plug ContentoWeb.Plug.AuthRequired
    plug :put_layout, {ContentoWeb.LayoutView, "contento.html"}
  end

  pipeline :theme do
    plug :put_layout, {ContentoWeb.ThemeView, "layout.html"}
  end

  pipeline :session do
    plug :put_layout, {ContentoWeb.SessionView, "layout.html"}
  end

  if Mix.env == :dev do
    scope "/debug" do
      forward "/sent_emails", Bamboo.EmailPreviewPlug
    end
  end

  scope "/c", ContentoWeb, as: :admin do
    pipe_through [:browser, :contento]

    # Account
    scope "/account" do
      get "/", AccountController, :index
      put "/", AccountController, :update
      put "/password", AccountController, :update_password
    end

    # Dashboard
    get "/", DashboardController, :index

    # Users
    resources "/users", UserController, except: [:edit]

    # Posts
    resources "/posts", PostController, except: [:edit]

    # Pages
    resources "/pages", PageController, except: [:edit]

    # Settings
    get "/settings", SettingsController, :show
    put "/settings", SettingsController, :update
  end

  scope "/", ContentoWeb do
    pipe_through [:browser, :session]

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete

    get "/activate/:token", SessionController, :activate
  end

  scope "/", ContentoWeb do
    pipe_through [:browser, :theme]

    # Index
    get "/", ThemeController, :index, as: :web

    # Page or Post
    get "/:slug", ThemeController, :page_or_post, as: :web
  end
end