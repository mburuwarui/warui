defmodule Warui.Treasury.Helpers.TypeCacheStartup do
  use GenServer
  alias Warui.Treasury.Helpers.TypeCache

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_) do
    # Initialize all type caches
    TypeCache.init_caches()
    {:ok, %{}}
  end
end
