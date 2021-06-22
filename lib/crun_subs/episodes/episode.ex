defmodule CrunSubs.Episodes.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  alias CrunSubs.Seasons.Season

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "episodes" do
    field :name, :string
    field :desc, :string
    belongs_to :season, Season

    timestamps()
  end
end
