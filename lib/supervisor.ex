defmodule Exsftpd.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    event_handler_options = Application.get_env(:exsftpd, Exsftpd.Watcher)
    children = [
      worker(Exsftpd.Server, [[]]),
      worker(Exsftpd.Watcher, [event_handler_options])
    ]
    supervise(children, strategy: :one_for_one)

  end

end
