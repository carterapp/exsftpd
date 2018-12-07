defmodule Exsftpd do
  use Application
  require Logger

  def status(options \\ nil) do
    Exsftpd.Server.status(Exsftpd.Server, options)
  end

  def state() do
    Exsftpd.Server.state(Exsftpd.Server)
  end

  def stop_daemon() do
    Exsftpd.Server.stop_daemon(Exsftpd.Server)
  end

  def start_daemon() do
    Exsftpd.Server.start_daemon(Exsftpd.Server)
  end

  def start_daemon(options) do
    Exsftpd.Server.start_daemon(Exsftpd.Server, options)
  end

  def start(_type, _args) do
    Exsftpd.Supervisor.start_link()
  end
end
