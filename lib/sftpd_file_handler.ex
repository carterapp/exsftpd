defmodule Exsftpd.SftpFileHandler do

  defp user_path(path, state) do
    Path.join(state[:root_path], path)

  end
  def close(io_device, state) do
    {:file.close(io_device), state}
  end

  def delete(path, state) do
    {:file.delete(user_path(path, state)), state}
  end

  def del_dir(path, state) do
    {:file.del_dir(user_path(path, state)), state}
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
    {:file.make_dir(user_path(dir, state)), state}
  end

  def make_symlink(path2, path, state) do
    {:file.make_symlink(user_path(path2, state), user_path(path, state)), state}
  end

  def open(path, flags, state) do
    {:file.open(user_path(path, state), flags), state}
  end

  def position(io_device, offs, state) do
    {:file.position(io_device, offs), state}
  end

  def read(io_device, len, state) do
    {:file.read(io_device, len), state}
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
    {:file.rename(user_path(path, state), user_path(path2, state)), state}
  end

  def write(io_device, data, state) do
    {:file.write(io_device, data), state}
  end

  def write_file_info(path, info, state) do
    {:file.write_file_info(user_path(path, state), info), state}
  end
end
