defmodule Exsftpd.SftpFileHandler do
  require Logger

  defp user_path(path, user) do

  end
  def close(io_device, state) do
    {:file.close(io_device), state}
  end

  def delete(path, state) do
    {:file.delete(path), state}
  end

  def del_dir(path, state) do
    {:file.del_dir(path), state}
  end

  def get_cwd(state) do
    {:file.get_cwd(), state}
  end

  def is_dir(abs_path, state) do
    {:filelib.is_dir(abs_path), state}
  end

  def list_dir(abs_path, state) do
    Logger.info("LIST: #{abs_path} #{inspect state}")
    {:file.list_dir(abs_path), state}
  end

  def make_dir(dir, state) do
    {:file.make_dir(dir), state}
  end

  def make_symlink(path2, path, state) do
    {:file.make_symlink(path2, path), state}
  end

  def open(path, flags, state) do
    {:file.open(path, flags), state}
  end

  def position(io_device, offs, state) do
    {:file.position(io_device, offs), state}
  end

  def read(io_device, len, state) do
    {:file.read(io_device, len), state}
  end

  def read_link(path, state) do
    {:file.read_link(path), state}
  end

  def read_link_info(path, state) do
    {:file.read_link_info(path), state}
  end

  def read_file_info(path, state) do
    {:file.read_file_info(path), state}
  end

  def rename(path, path2, state) do
    {:file.rename(path, path2), state}
  end

  def write(io_device, data, state) do
    {:file.write(io_device, data), state}
  end

  def write_file_info(path, info, state) do
    {:file.write_file_info(path, info), state}
  end
end
