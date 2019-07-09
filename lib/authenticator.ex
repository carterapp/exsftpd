defmodule Exsftpd.Authenticator do
  def accept_all(_user, _password, _opts) do
    true
  end
end
