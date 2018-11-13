use Mix.Config

config :exsftpd, Exsftpd.Server,
  port: 2220,
  #root dir for <username>: /tmp/users/<username>/files
  user_root_dir: fn(user)->"/tmp/users/#{user}/files" end,
  #look for authorized_keys at /tmp/users/<username>/.ssh
  user_auth_dir: "/tmp/users",
  #Where to look for ssh host keys
  system_dir: "/tmp/ssh"