defmodule WaruiWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  # configure your UI overrides here

  # First argument to `override` is the component name you are overriding.
  # The body contains any number of configurations you wish to override
  # Below are some examples

  # For a complete reference, see https://hexdocs.pm/ash_authentication_phoenix/ui-overrides.html

  override AshAuthentication.Phoenix.Components.Banner do
    set :image_url, "/images/logo.jpg"
    set :dark_image_url, "/images/logo.jpg"
    set :image_class, "block dark:hidden rounded-lg h-auto w-24"
    set :dark_image_class, "hidden dark:block rounded-lg h-auto w-24"
  end

  override AshAuthentication.Phoenix.Components.Password.Input do
    set :field_class, "mt-2 mb-2 text-base-content"
    set :label_class, "block text-sm font-medium text-base-700 mb-1"

    @base_input_class """
    appearance-none block w-full px-3 py-2 border rounded-md
    shadow-sm placeholder-gray-400 focus:outline-none sm:text-sm
    text-base-content
    """

    set :input_class,
        @base_input_class <>
          """
          border-accent/30 focus:ring-accent/60 focus:border-accent/60
          """

    set :submit_class, """
    w-full flex justify-center py-2 px-4 border border-transparent rounded-md
    shadow-sm text-sm font-medium text-base-700 bg-primary/80 hover:bg-primary
    focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-accent/50
    mt-4 mb-4
    """
  end

  override AshAuthentication.Phoenix.SignInLive do
    set :root_class, "grid h-screen place-items-center bg-neutral/10"
  end

  # override AshAuthentication.Phoenix.Components.SignIn do
  #  set :show_banner, false
  # end
end
