defmodule Exsftpd.MixProject do
  use Mix.Project

  def project do
    [
      app: :exsftpd,
      description: description(),
      version: "0.9.0",
      elixir: "~> 1.4 or ~> 1.5 or ~> 1.6 or ~> 1.7 or ~> 1.8 or ~> 1.9",
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
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "exsftpd",
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/carterapp/exsftpd"}
    ]
  end
end
