# Exsftpd

[![Build Status](https://travis-ci.com/Codenaut/exsftpd.svg?branch=master)](https://travis-ci.com/Codenaut/exsftpd)

SFTP server which do not allow shell access and has a separate root directory
for each user.

## Installation

The package can be installed by adding `exsftpd` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:exsftpd, "~> 0.10.1"}
  ]
end
```

Next add a configuration entry for `:exsftpd, Exsftpd.Server`:
```
config :exsftpd, Exsftpd.Server,
  port: 2220,
  #root dir for <someuser>: /tmp/users/files/<someuser>
  user_root_dir: "/tmp/users/files",
  #look for authorized_keys at /tmp/users/<username>/.ssh
  user_auth_dir: "/tmp/users",
  #Where to look for ssh host keys
  system_dir: "/tmp/ssh",
  event_handler: fn(event) -> IO.puts("Event: #{inspect event} ") end

```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exsftpd](https://hexdocs.pm/exsftpd).

