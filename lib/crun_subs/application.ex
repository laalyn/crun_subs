defmodule CrunSubs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    "[info] Starting CrunSubs.Application (#{:erlang.system_info(:emu_flavor)}, #{:erlang.system_info(:emu_type)})"
    |> IO.puts()

    children = [
      # Start the Ecto repository
      CrunSubs.Repo,
      # Start the Telemetry supervisor
      CrunSubsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CrunSubs.PubSub},
      # Start the Endpoint (http/https)
      CrunSubsWeb.Endpoint
      # Start a worker by calling: CrunSubs.Worker.start_link(arg)
      # {CrunSubs.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CrunSubs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CrunSubsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
