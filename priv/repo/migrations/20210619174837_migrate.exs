defmodule CrunSubs.Repo.Migrations.Migrate do
  use Ecto.Migration

  def change do
    create table(:shows, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :url, :string # must not have trailing slash
      add :lang, :string # e.g. enUS

      timestamps([type: :utc_datetime_usec])
    end

    create table(:seasons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :show_id, references(:shows, [type: :binary_id, on_delete: :delete_all])

      timestamps([type: :utc_datetime_usec])
    end

    create table(:episodes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :desc, :text
      add :season_id, references(:seasons, [type: :binary_id, on_delete: :delete_all])

      timestamps([type: :utc_datetime_usec])
    end

    create table(:subtitles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :source, :text
      add :episode_id, references(:episodes, [type: :binary_id, on_delete: :delete_all])

      timestamps([type: :utc_datetime_usec])
    end

    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :idx, :bigint
      add :val, :text
      add :subtitle_id, references(:subtitles, [type: :binary_id, on_delete: :delete_all])

      timestamps([type: :utc_datetime_usec])
    end

    # unique constraints
    create unique_index(:shows, [:url, :lang])
    create unique_index(:seasons, [:name, :show_id])
    create unique_index(:episodes, [:name, :season_id])
    create unique_index(:subtitles, [:episode_id])
    create unique_index(:events, [:idx, :subtitle_id])

    # join speedups
    create index(:seasons, [:show_id])
    create index(:episodes, [:season_id])
    create index(:events, [:subtitle_id])
  end
end
