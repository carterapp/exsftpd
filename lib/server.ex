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
  Stop daemon
  """
  def start_daemon(pid, options) do
    GenServer.cast(pid, {:start_daemon, options})
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

  defp dummy_shell(user, {ip, _port}) do
    spawn(fn ->
      remote_ip = ip |> Tuple.to_list() |> Enum.join(".")
      IO.puts("Hello, #{user} from #{remote_ip}")
      IO.puts("No shell available for you here")
    end)
  end

  defp system_dir(env) do
    if !env[:system_dir] do
      raise "Missing system_dir"
    end

    get_charlist(:system_dir, env)
  end

  defp user_root_dir(env) do
    if !env[:user_root_dir] do
      raise "Missing user_root_dir"
    end

    env[:user_root_dir]
  end

  defp user_auth_dir(env) do
    if !env[:user_auth_dir] && !env[:user_root_dir] do
      raise "Missing user_root_dir or user_auth_dir"
    end

    fn user ->
      dir_or_fun = env[:user_auth_dir] || env[:user_root_dir]

      if is_function(dir_or_fun) do
        dir_or_fun.(user)
      else
        "#{dir_or_fun}/#{user}/.ssh"
      end
    end
  end

  defp init_daemon() do
    env = Application.get_env(:exsftpd, Exsftpd.Server)
    init_daemon(env)
  end

  defp init_daemon(env) do
    {:ok, ref} =
      :ssh.daemon(env[:port],
        system_dir: system_dir(env),
        shell: &dummy_shell/2,
        subsystems: [
          Exsftpd.SftpdChannel.subsystem_spec(
            file_handler: {Exsftpd.SftpFileHandler, [user_root_dir: user_root_dir(env)]},
            cwd: '/'
          )
        ],
        user_dir_fun: user_auth_dir(env)
      )

    {:ok, ref, env}
  end

  def init(options) do
    :ok = :ssh.start()

    {:ok, ref, env} = init_daemon()

    {:ok, %{daemon_ref: ref, options: options, env: env}}
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

  def handle_cast({:start_daemon, options}, state) do
    {:ok, ref} = init_daemon(options)
    new_state = Map.put(state, :daemon_ref, ref)
    {:noreply, new_state}
  end
end
