defmodule CrunSubs.Subtitles.Subtitle do
  use Ecto.Schema
  import Ecto.Changeset

  alias CrunSubs.Episodes.Episode

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "subtitles" do
    field :source, :string
    belongs_to :episode, Episode

    timestamps()
  end
end
