defmodule Exsftpd.Events do
  require Logger

  def log_event(event) do
    Logger.debug("#{inspect(event)}")
  end
end
