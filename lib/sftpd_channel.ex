defmodule Exsftpd.SftpdChannel do
  @behaviour :ssh_server_channel

  require Logger
  require Record

  Record.defrecord(:state,  Record.extract(:state, from_lib: "ssh/src/ssh_sftpd.erl"))
  Record.defrecord(:ssh_xfer,  Record.extract(:ssh_xfer, from_lib: "ssh/src/ssh_xfer.erl"))

  def subsystem_spec(options) do
    {'sftp', {Exsftp.SftpdChannel, options}}
  end

  def init(options) do
    :ssh_sftpd.init(options)
  end

  def handle_msg(msg, state) do
    :ssh_sftpd.handle_msg(msg, state)
  end

  def handle_ssh_msg(msg, state) do
    s = state(state)
    xf = ssh_xfer(s[:xf])
    [user: username] = :ssh.connection_info(xf[:cm], [:user])
    file_state = List.keystore(s[:file_state], :user, 0, {:user, username})
    Logger.info("msg #{inspect state}")
    Logger.info("msg2 #{inspect s}")

    :ssh_sftpd.handle_ssh_msg(msg, state)
  end

  def terminate(reason, state) do
    :ssh_sftpd.terminate(reason, state)
  end
end
