defmodule Exsftpd.SftpdChannel do
  @behaviour :ssh_server_channel

  require Logger
  require Record

  Record.defrecord(:state, Record.extract(:state, from_lib: "ssh/src/ssh_sftpd.erl"))
  Record.defrecord(:ssh_xfer, Record.extract(:ssh_xfer, from_lib: "ssh/src/ssh_xfer.erl"))

  def subsystem_spec(options) do
    {'sftp', {Exsftpd.SftpdChannel, options}}
  end

  def init(options) do
    :ssh_sftpd.init(options)
  end

  def handle_msg(msg, state) do
    :ssh_sftpd.handle_msg(msg, state)
  end

  defp to_record(record) do
    Enum.map(record, fn {_k, v} -> v end) |> Enum.into([:state]) |> List.to_tuple()
  end

  defp populate_file_state(state) do
    file_state = state[:file_state]

    if file_state[:user] do
      file_state
    else
      user_root_dir = file_state[:user_root_dir]

      xf = ssh_xfer(state[:xf])
      [user: username] = :ssh.connection_info(xf[:cm], [:user])
      root_path = "#{user_root_dir}/#{username}"
      :file.make_dir(root_path)

      file_state
      |> List.keystore(:user, 0, {:user, username})
      |> List.keystore(:root_path, 0, {:root_path, root_path})
    end
  end

  def handle_ssh_msg(msg, state) do
    s = state(state)
    file_state = populate_file_state(s)
    new_state = List.keystore(s, :file_state, 0, {:file_state, file_state})
    :ssh_sftpd.handle_ssh_msg(msg, to_record(new_state))
  end

  def terminate(reason, state) do
    :ssh_sftpd.terminate(reason, state)
  end
end
