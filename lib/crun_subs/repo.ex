defmodule CrunSubs.Repo do
  use Ecto.Repo,
    otp_app: :crun_subs,
    adapter: Ecto.Adapters.Postgres
end
