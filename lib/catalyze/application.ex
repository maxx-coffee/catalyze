defmodule Catalyze.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CatalyzeWeb.Telemetry,
      Catalyze.Repo,
      {DNSCluster, query: Application.get_env(:catalyze, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Catalyze.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Catalyze.Finch},
      # Start a worker by calling: Catalyze.Worker.start_link(arg)
      # {Catalyze.Worker, arg},
      # Start to serve requests, typically the last entry
      CatalyzeWeb.Endpoint,
      Catalyze.Presence,
      Catalyze.DbSupervisor,
      {Registry, keys: :unique, name: CatalyzeRegistry}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Catalyze.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CatalyzeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
