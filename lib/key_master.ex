defmodule Exsftpd.KeyMaster do
  @behaviour :ssh_server_key_api
  require Logger

  # Simple example of how to implement as ssh_server_key_api 
  # behaviour. This simply falls back to :ssh_file, but
  # the keys could come from anywhere

  @impl true
  def is_auth_key(key, user, options) do
    Logger.debug("is_auth_key:\nkey: #{inspect(key)}\n#{inspect(user)}\n#{inspect(options)}")
    :ssh_file.is_auth_key(key, user, options)
  end

  @impl true
  def host_key(algorithm, options) do
    Logger.debug("host_key:\nalgorithm: #{inspect(algorithm)}\n#{inspect(options)}")
    :ssh_file.host_key(algorithm, options)
  end
end
