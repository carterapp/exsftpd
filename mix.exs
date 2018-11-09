defmodule Exsftpd.MixProject do
  use Mix.Project

  def project do
    [
      app: :exsftpd,
      description: description(),
      version: "0.3.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def description() do
    "SFTP server with separate root directories for each user"
  end

  def module() do
    if Mix.env() == :test do
      []
    else
      {Exsftpd, []}
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: module(),
      extra_applications: [:logger, :ssh]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "exsftpd",
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/Codenaut/exsftpd"}
    ]
  end
end
