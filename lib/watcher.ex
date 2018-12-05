defmodule Exsftpd.Watcher do
  use GenServer


  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def on_event(event) do
    GenServer.cast(__MODULE__, {:on_event, event})
  end

  def init(options) do
    {:ok, options}
  end

  def handle_cast({:on_event, event}, state) do
    handler = state[:event_handler]
    if handler do
      handler.(event)
    end
    {:noreply, state}
  end
end
