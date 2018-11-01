defmodule ExsftpdTest do
  use ExUnit.Case, async: true
  doctest Exsftpd

  setup do
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
