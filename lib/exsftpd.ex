defmodule Exsftpd do
  @moduledoc """
  Documentation for Exsftp.
  """

  def init do
    :ssh.start()

    {:ok, _ref} =
      :ssh.daemon(2220,
        system_dir: '/tmp/ssh',
        shell: fn _ -> {:ok, 'Bye'} end,
        subsystems: [
          Exsftpd.SftpdChannel.subsystem_spec(
            file_handler: {Exsftpd.SftpFileHandler, []}
          )
        ],
        user_dir_fun: fn user ->
          "/tmp/#{user}/.ssh"
        end
      )
  end
end
