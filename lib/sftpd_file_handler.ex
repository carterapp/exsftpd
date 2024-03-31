defmodule Exsftpd.SftpFileHandler do
  defp user_path(path, state) do
    Path.join(state[:root_path], path)
  end

  defp on_event({event_name, meta}, state) do
    case state[:event_handler] do
      nil -> nil
      {module, fun} -> apply(module, fun, [{event_name, state[:user], meta}])
      handler -> handler.({event_name, state[:user], meta})
    end
  end

  defp after_event(param, state, result) do
    on_event(param, state)
    result
  end

  defp pid2name(io_device) when is_pid(io_device) do
    # This function has code ported from the deprecated Erlang function :file.pid2name.

    ref = Process.monitor(io_device)

    send(io_device, {:file_request, self(), ref, :pid2name})

    receive do
      {:file_reply, ref, reply} ->
        Process.demonitor(ref, [:flush])
        reply

      {"DOWN", _ref, _, _, _} ->
        {:error, :terminated}
    after
      500 ->
        {:error, :timeout}
    end
  end

  defp get_file_info(io_device) do
    case pid2name(io_device) do
      {:ok, filename} -> {io_device, filename}
      _ -> {io_device}
    end
  end

  def close(io_device, state) do
    after_event({:close, get_file_info(io_device)}, state, {:file.close(io_device), state})
  end

  def delete(path, state) do
    after_event({:delete, path}, state, {:file.delete(user_path(path, state)), state})
  end

  def del_dir(path, state) do
    after_event({:del_dir, path}, state, {:file.del_dir(user_path(path, state)), state})
  end

  def get_cwd(state) do
    {:file.get_cwd(), state}
  end

  def is_dir(abs_path, state) do
    {:filelib.is_dir(user_path(abs_path, state)), state}
  end

  def list_dir(abs_path, state) do
    {:file.list_dir(user_path(abs_path, state)), state}
  end

  def make_dir(dir, state) do
    after_event({:make_dir, dir}, state, {:file.make_dir(user_path(dir, state)), state})
  end

  def make_symlink(path2, path, state) do
    after_event(
      {:make_symlink, {path2, path}},
      state,
      {:file.make_symlink(user_path(path2, state), user_path(path, state)), state}
    )
  end

  def open(path, flags, state) do
    {case :file.open(user_path(path, state), flags) do
       {:ok, pid} ->
         on_event({:open, {get_file_info(pid), path, flags}}, state)
         {:ok, pid}

       other ->
         other
     end, state}
  end

  def position(io_device, offs, state) do
    {:file.position(io_device, offs), state}
  end

  def read(io_device, len, state) do
    after_event({:read, get_file_info(io_device)}, state, {:file.read(io_device, len), state})
  end

  def read_link(path, state) do
    {:file.read_link(user_path(path, state)), state}
  end

  def read_link_info(path, state) do
    {:file.read_link_info(user_path(path, state)), state}
  end

  def read_file_info(path, state) do
    {:file.read_file_info(user_path(path, state)), state}
  end

  def rename(path, path2, state) do
    after_event(
      {:rename, {path, path2}},
      state,
      {:file.rename(user_path(path, state), user_path(path2, state)), state}
    )
  end

  def write(io_device, data, state) do
    after_event({:write, get_file_info(io_device)}, state, {:file.write(io_device, data), state})
  end

  def write_file_info(path, info, state) do
    after_event(
      {:write_file_info, {path, info}},
      state,
      {:file.write_file_info(user_path(path, state), info), state}
    )
  end
end
