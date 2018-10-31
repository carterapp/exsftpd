defmodule ExsftpdTest do
  use ExUnit.Case
  doctest Exsftpd

  test "greets the world" do
    assert Exsftpd.hello() == :world
  end
end
