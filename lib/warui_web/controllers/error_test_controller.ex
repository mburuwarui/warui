defmodule WaruiWeb.ErrorTestController do
  use WaruiWeb, :controller

  def test_500(_conn, _params) do
    # This will trigger a 500 error
    raise "Testing 500 error page"
  end
end
