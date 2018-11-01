defmodule Exsftpd.Server do
  use GenServer

  @moduledoc """
  Documentation for Exsftp.
  """

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(name, opts) do
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Stop daemon
  """
  def stop_daemon(pid) do
    GenServer.cast(pid, {:stop_daemon})
  end

  @doc """
  Stop daemon
  """
  def start_daemon(pid) do
    GenServer.cast(pid, {:start_daemon})
  end

  @doc """
  Daemon status
  """
  def status(pid) do
    GenServer.call(pid, {:status})
  end

  ## Server Callbacks

  defp get_charlist(key, env) do
    v = env[key]
    v && v |> String.to_charlist()
  end

  defp init_daemon(options) do
    :file.set_cwd("/tmp")

    :ssh.daemon(options[:port],
      system_dir: get_charlist(:system_dir, options),
      shell: fn _ -> {:ok, 'Bye'} end,
      subsystems: [
        Exsftpd.SftpdChannel.subsystem_spec(
          file_handler: {Exsftpd.SftpFileHandler, [user_root_dir: options[:user_root_dir]]},
          cwd: '/'
        )
      ],
      user_dir_fun: fn user ->
        dir = options[:user_auth_dir] || options[:user_root_dir]
        "#{dir}/#{user}/.ssh"
      end
    )
  end

  def init(options) do
    :ok = :ssh.start()

    {:ok, ref} = init_daemon(options)

    {:ok, %{daemon_ref: ref, options: options}}
  end

  def handle_call({:status}, _from, state) do
    {:reply, :ssh.daemon_info(state.daemon_ref), state}
  end

  def handle_cast({:stop_daemon}, state) do
    :ok = :ssh.stop_daemon(state.daemon_ref)
    {:noreply, state}
  end

  def handle_cast({:start_daemon}, state) do
    {:ok, ref} = init_daemon(state.options)
    new_state = Map.put(state, :daemon_ref, ref)
    {:noreply, new_state}
  end
end
