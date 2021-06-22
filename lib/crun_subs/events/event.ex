defmodule CrunSubs.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias CrunSubs.Subtitles.Subtitle

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "events" do
    field :idx, :integer
    field :val, :string
    belongs_to :subtitle, Subtitle

    timestamps()
  end
end
