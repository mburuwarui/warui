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
    Logger.info("Starting TypeCache initialization and database seeding")

    # First, create the system user
    user = TypeCache.system_user()
    Logger.info("System user and organizatiion created successfully: #{inspect(user)}")

    # Then start the seeding tasks
    Task.start(fn ->
      try do
        Logger.info("Starting treasury types seeding")
        Seeder.seed_treasury_types(user)
        Logger.info("Treasury types seeding completed")

        Logger.info("Starting cache initialization")
        TypeCache.init_caches(user)
        Logger.info("Cache initialization completed")

        Logger.info("TypeCache initialization and database seeding completed successfully")
      rescue
        e ->
          Logger.error("TypeCache initialization and database seeding failed: #{inspect(e)}")
          Logger.error("Error details: #{Exception.format(:error, e, __STACKTRACE__)}")
      end
    end)

    {:ok, %{}}
  end
end
