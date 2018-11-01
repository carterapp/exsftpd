defmodule Exsftpd.Server do
  use GenServer
  require Logger

  @moduledoc """
  Documentation for Exsftp.
  """

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
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

  def state(pid) do
    GenServer.call(pid, {:state})
  end

  ## Server Callbacks

  defp get_charlist(key, env) do
    v = env[key]
    v && v |> String.to_charlist()
  end

  defp dummy_shell(user) do
    spawn(fn() ->
      IO.puts("Hello, #{user}.")
      IO.puts("No shell available for you here")
    end)
  end

  defp init_daemon() do
    env = Application.get_env(:exsftpd, Exsftpd.Server)
    :file.set_cwd("/tmp")

    :ssh.daemon(env[:port],
      system_dir: get_charlist(:system_dir, env),
      shell: &dummy_shell/1,
      subsystems: [
        Exsftpd.SftpdChannel.subsystem_spec(
          file_handler: {Exsftpd.SftpFileHandler, [user_root_dir: env[:user_root_dir]]},
          cwd: '/'
        )
      ],
      user_dir_fun: fn user ->
        dir = env[:user_auth_dir] || env[:user_root_dir]
        "#{dir}/#{user}/.ssh"
      end
    )
  end

  def init(options) do
    :ok = :ssh.start()

    {:ok, ref} = init_daemon()

    {:ok, %{daemon_ref: ref, options: options}}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:status}, _from, state) do
    if state[:daemon_ref] do
      {:reply, :ssh.daemon_info(state.daemon_ref), state}
    else
      {:reply, {:error, :down}, state}
    end
  end

  def handle_cast({:stop_daemon}, state) do
    :ok = :ssh.stop_daemon(state.daemon_ref)
    {_, new_state} = Map.pop(state, :daemon_ref)
    {:noreply, new_state}
  end

  def handle_cast({:start_daemon}, state) do
    {:ok, ref} = init_daemon()
    new_state = Map.put(state, :daemon_ref, ref)
    {:noreply, new_state}
  end
end
