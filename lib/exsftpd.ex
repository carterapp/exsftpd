defmodule Exsftpd do
  def status() do
    Exsftpd.Server.status(Exsftpd.Server)
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
end
