defmodule CatalyzeWeb.ReportChannel do
  use CatalyzeWeb, :channel
  alias Catalyze.Presence

  @impl true
  def join("report:" <> name, _payload, socket) do
    send(self(), {:after_join, name})
    {:ok, socket}
  end

  @impl true
  def handle_info({:after_join, name}, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:second))
      })

    Catalyze.DbSupervisor.add_child(name)
    {:noreply, socket}
  end
end
