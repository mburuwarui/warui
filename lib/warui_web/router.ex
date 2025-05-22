defmodule WaruiWeb.Router do
  use WaruiWeb, :router

  import Oban.Web.Router
  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :graphql do
    plug :load_from_bearer
    plug :set_actor, :user
    plug AshGraphql.Plug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WaruiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
    plug AshAuthentication.Strategy.ApiKey.Plug, resource: Warui.Accounts.User
  end

  pipeline :mcp do
    plug AshAuthentication.Strategy.ApiKey.Plug,
      resource: Warui.Accounts.User,
      # Use `required?: false` to allow unauthenticated
      # users to connect, for example if some tools
      # are publicly accessible.
      required?: false
  end

  scope "/", WaruiWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {WaruiWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {WaruiWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {WaruiWeb.LiveUserAuth, :live_no_user}
      #
      scope "/accounts/groups", Accounts.Groups do
        live "/", GroupsLive
        live "/:group_id/permissions", GroupPermissionsLive
      end
    end
  end

  scope "/mcp" do
    pipe_through :mcp

    forward "/", AshAi.Mcp.Router,
      tools: [
        :list,
        :of,
        :tools
      ],
      # If using mcp-remote, and this issue is not fixed yet: https://github.com/geelen/mcp-remote/issues/66
      # You will need to set the `protocol_version_statement` to the
      # older version.
      protocol_version_statement: "2024-11-05",
      otp_app: :my_app
  end

  scope "/api/json" do
    pipe_through [:api]

    forward "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
      path: "/api/json/open_api",
      default_model_expand_depth: 4

    forward "/", WaruiWeb.AshJsonApiRouter
  end

  scope "/gql" do
    pipe_through [:graphql]

    forward "/playground", Absinthe.Plug.GraphiQL,
      schema: Module.concat(["WaruiWeb.GraphqlSchema"]),
      socket: Module.concat(["WaruiWeb.GraphqlSocket"]),
      interface: :playground

    forward "/", Absinthe.Plug, schema: Module.concat(["WaruiWeb.GraphqlSchema"])
  end

  scope "/", WaruiWeb do
    pipe_through :browser

    get "/", PageController, :home
    auth_routes AuthController, Warui.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{WaruiWeb.LiveUserAuth, :live_no_user}],
                  overrides: [WaruiWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [WaruiWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not use the confirmation strategy
    confirm_route Warui.Accounts.User, :confirm_new_user,
      auth_routes_prefix: "/auth",
      overrides: [WaruiWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not use the magic link strategy.
    magic_sign_in_route(Warui.Accounts.User, :magic_link,
      auth_routes_prefix: "/auth",
      overrides: [WaruiWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", WaruiWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:warui, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WaruiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    scope "/" do
      pipe_through :browser

      oban_dashboard("/oban")
    end
  end

  if Application.compile_env(:warui, :dev_routes) do
    import AshAdmin.Router

    scope "/admin" do
      pipe_through :browser

      ash_admin "/"
    end
  end
end
