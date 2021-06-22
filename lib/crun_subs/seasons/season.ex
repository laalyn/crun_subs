defmodule CrunSubs.Seasons.Season do
  use Ecto.Schema
  import Ecto.Changeset

  alias CrunSubs.Shows.Show

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "seasons" do
    field :name, :string
    belongs_to :show, Show

    timestamps()
  end
end
