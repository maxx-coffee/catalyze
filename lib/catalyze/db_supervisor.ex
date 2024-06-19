defmodule Catalyze.DbSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_child(name) do
    DynamicSupervisor.start_child(__MODULE__, {Catalyze.DbInstance, name})
  end
end
