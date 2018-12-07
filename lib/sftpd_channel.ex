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

  def ensure_dir(path) do
    Path.split(path)
    |> Enum.reduce_while({:ok, ""}, fn (p, {_, parent}) ->
      dir = "#{parent}/#{p}"
      case :file.make_dir(dir) do
        :ok -> {:cont, {:ok, dir}}
        {:error, :eexist} -> {:cont, {:ok, dir}}
        {:error, :eisdir} -> {:cont, {:ok, dir}}
        other -> {:halt, other}
      end
    end)
  end

  defp populate_file_state(state) do
    file_state = state[:file_state]

    if file_state[:user] do
      file_state
    else
      event_handler = file_state[:event_handler]

      user_root_dir = file_state[:user_root_dir]

      xf = ssh_xfer(state[:xf])
      [user: username] = :ssh.connection_info(xf[:cm], [:user])

      root_path =
        if is_function(user_root_dir) do
          user_root_dir.(username)
        else
          "#{user_root_dir}/#{username}"
        end

      #make sure directory exists
      {:ok, _path} = ensure_dir(root_path)

      file_state
      |> List.keystore(:event_handler, 0, {:event_handler, event_handler})
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
