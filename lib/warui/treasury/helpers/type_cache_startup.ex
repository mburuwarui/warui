defmodule Warui.Treasury.Helpers.TypeCacheStartup do
  use GenServer
  alias Warui.Treasury.Helpers.TypeCache

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init([]) do
    # Start cache initialization in a separate process to avoid holding up startup
    Task.start(fn ->
      try do
        TypeCache.init_caches()
        Logger.info("TypeCache initialization completed successfully")
      rescue
        e ->
          Logger.error("TypeCache initialization failed: #{inspect(e)}")
          # Allow the application to continue starting even if cache init fails
          # The cache will be initialized on first access
      end
    end)

    {:ok, %{}}
  end
end
