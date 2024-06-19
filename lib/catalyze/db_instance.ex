defmodule Catalyze.DbInstance do
  use GenServer, restart: :transient

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{db: nil, conn: nil, name: name}, name: get_name(name))
  end

  def get_db(name) do
    case check_db(name) do
      :ok -> {:ok, GenServer.call(get_name(name), :get_db)}
      _ -> {:error, :not_found}
    end
  end

  def kill(name) do
    case check_db(name) do
      :ok -> GenServer.stop(get_name(name))
      _ -> :ok
    end
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :set_db}}
  end

  @impl true
  def handle_continue(:set_db, %{name: name}) do
    try do
      {:ok, db} = Duckdbex.open("db/#{name}.db") |> IO.inspect()
      {:ok, conn} = Duckdbex.connection(db)
      CatalyzeWeb.Endpoint.subscribe("report:#{name}") |> IO.inspect()
      {:noreply, %{db: db, conn: conn, name: name}}
    rescue
      _ ->
        {:noreply, {nil, nil}}
    end
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{leaves: %{"1" => _}}},
        state
      ) do
    {:stop, :normal, state}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: %{"1" => _}}},
        state
      ) do
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_db, _from, state) do
    {:reply, state, state}
  end

  def get_name(name) do
    {:via, Registry, {CatalyzeRegistry, name}}
  end

  defp check_db(name) do
    case Registry.lookup(CatalyzeRegistry, name) |> IO.inspect() do
      [_] -> :ok
      _ -> :error
    end
  end
end
