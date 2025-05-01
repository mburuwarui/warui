defmodule Warui.Treasury.Helpers.TypeCacheStartup do
  use GenServer
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init([]) do
    user = TypeCache.system_user()

    Task.start(fn ->
      try do
        TypeCache.init_caches(user)
        Seeder.seed_treasury_types(user)
        Logger.info("TypeCache initialization and database seeding completed successfully")
      rescue
        e ->
          Logger.error("TypeCache initialization and database seeding failed: #{inspect(e)}")
      end
    end)

    {:ok, %{}}
  end
end
