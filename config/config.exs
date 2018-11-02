# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :exsftpd, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:exsftpd, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

config :exsftpd, Exsftpd.Server,
  port: 2220,
  #root dir for <username>: /tmp/users/<username>/files
  user_root_dir: fn(user)->"/tmp/users/#{user}/files" end,
  #look for authorized_keys at /tmp/users/<username>/.ssh
  user_auth_dir: "/tmp/users",
  #Where to look for ssh host keys
  system_dir: "/tmp/ssh"


# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"
