defmodule ExsftpdTest do
  use ExUnit.Case, async: true
  doctest Exsftpd

  setup do
    root_dir = Application.get_env(:exsftpd, Exsftpd.Server)[:user_auth_dir]
    :file.make_dir(root_dir)
    server = start_supervised!(Exsftpd.Server)
    %{server: server}
  end

  test "lifecycle", %{server: server} do
    assert {:ok, _} = Exsftpd.Server.status(server)

    assert :ok = Exsftpd.Server.stop_daemon(server)
    assert {:error, :down} = Exsftpd.Server.status(server)

    assert :ok = Exsftpd.Server.start_daemon(server)
    assert {:ok, _ref} = Exsftpd.Server.status(server)
  end
end
