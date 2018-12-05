defmodule Exsftpd.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    options = Application.get_env(:exsftpd, Exsftpd.Server)
    children = [
      worker(Exsftpd.Server, [options]),
      worker(Exsftpd.Watcher, [options])
    ]
    supervise(children, strategy: :one_for_one)

  end

end
