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
  def stop_daemon(pid, options \\ nil) do
    GenServer.call(pid, {:stop_daemon, options})
  end

  @doc """
  Start daemon
  """
  def start_daemon(pid, options \\ nil) do
    GenServer.call(pid, {:start_daemon, options})
  end

  @doc """
  Daemon status
  """
  def status(pid, options \\ nil) do
    GenServer.call(pid, {:status, options})
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

  defp init_daemon(options) do
    Logger.info("Starting SFTP daemon on #{options[:port]}")

    case :ssh.daemon(options[:port],
                     system_dir: system_dir(options),
                     shell: &dummy_shell/2,
                     subsystems: [
                       Exsftpd.SftpdChannel.subsystem_spec(
                         file_handler: {Exsftpd.SftpFileHandler,
                           [event_handler: options[:event_handler], user_root_dir: user_root_dir(options)]},
                           cwd: '/'
                       )
                     ],
                     user_dir_fun: user_auth_dir(options)
    ) do
      {:ok, pid} -> 
        ref = Process.monitor(pid)
        {:ok, pid, ref, options}
      any -> any
    end
  end

  def init(options) do
    :ok = :ssh.start()
    case options do
      nil -> {:ok, %{options: options, daemons: []}}
      env -> case init_daemon(env) do
        {:ok, pid, ref, options} ->
          {:ok, %{options: options, daemons: [%{pid: pid, ref: ref, options: options}]}}
        any -> any
      end
    end
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    daemon = find_daemon_by_pid(state.daemons, pid)
    if daemon do
      Logger.info("Restarting SSH daemon: #{inspect daemon.options}")
      GenServer.cast(self(), {:start_daemon, daemon.options})
      {:noreply, state |> Map.put(:daemons, remove_daemon(state.daemons, pid))}
    else
    {:noreply, state}
    end
  end

  def handle_info({:stop_ssh_daemon, pid}, state) do
    :ssh.stop_daemon(pid)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:status, options}, _from, state) do
    opts = options || state.options
    daemon = find_daemon(state.daemons, opts)
    if daemon do
      {:reply, :ssh.daemon_info(daemon.pid), state}
    else
      {:reply, {:error, :down}, state}
    end
  end

  def terminate(_reason, state) do
    state.daemons |> Enum.each(fn(d) ->
      :ssh.stop_daemon(d.pid)
    end)
  end


  def find_daemon(daemons, opts) do
    port = opts[:port]
    daemons |> Enum.find(&(&1.options[:port] == port))
  end

  def find_daemon_by_pid(daemons, pid) do
    daemons |> Enum.find(&(&1.pid == pid))
  end


  defp remove_daemon(daemons, pid) do
    daemons |> Enum.filter(&(&1.pid != pid))
  end


  def handle_cast({:start_daemon, options}, state) do
    opts = options || state.options
    case init_daemon(opts) do
      {:ok, pid, ref, options} ->
        {:noreply, state |> Map.put(:daemons, [%{pid: pid, ref: ref, options: options} | state.daemons]) }
      any ->
        Logger.error("Failed to start daemon: #{inspect any}")
        {:noreply, state}
    end
  end

  def handle_call({:stop_daemon, options}, _from, state) do
    opts = options || state.options
    daemon = find_daemon(state.daemons, opts)
    if daemon do
      Process.send(self(), {:stop_ssh_daemon, daemon.pid}, [])
      {:reply, {:ok, daemon}, state |> Map.put(:daemons, remove_daemon(state.daemons, daemon.pid))}
    else
      {:reply, {:error, :down}, state}
    end
  end


  def handle_call({:start_daemon, options}, _from, state) do
    opts = options || state.options
    case init_daemon(opts) do
      {:ok, pid, ref, options} ->
        {:reply, {:ok, pid}, state |> Map.put(:daemons, [%{pid: pid, ref: ref, options: options} | state.daemons]) }
      any ->
        {:reply, any, state}
    end
  end
end
