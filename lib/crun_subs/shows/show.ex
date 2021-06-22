defmodule CrunSubs.Shows.Show do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "shows" do
    field :name, :string
    field :url, :string
    field :lang, :string

    timestamps()
  end
end
