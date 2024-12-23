defmodule WaruiWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  # configure your UI overrides here

  # First argument to `override` is the component name you are overriding.
  # T                                                         he body contains any number of configurations you wish to override
  # Below are some examples

  # For a complete reference, see https://hexdocs.pm/ash_authentication_phoenix/ui-overrides.html

  override AshAuthentication.Phoenix.Components.Banner do
    set(:image_url, "/images/logo.jpg")
    set(:dark_image_url, nil)
    set(:image_class, "rounded-full h-auto w-32")
  end

  # override AshAuthentication.Phoenix.Components.Password do
  #   set(:slot_class, "bg-red-100")
  # end

  # override AshAuthentication.Phoenix.SignInLive do
  #   set(:root_class, "bg-zinc-200 dark:bg-zinc-800 h-screen")
  # end
end
