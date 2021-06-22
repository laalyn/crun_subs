defmodule CrunSubs.Shows do
  import Ecto.Query, warn: false
  alias Ecto.UUID
  alias CrunSubs.Repo

  alias CrunSubs.Shows.Show
  alias CrunSubs.Seasons.Season
  alias CrunSubs.Episodes.Episode
  alias CrunSubs.Subtitles.Subtitle
  alias CrunSubs.Events.Event

  def add_show(url, lang, mode, override, req_uuid) do
    mode = case mode do
      "all_or_nothing" -> :pristine
      "best_effort" -> :trash
    end

    override = if override do
      :replace_all
    else
      :nothing
    end

    # TODO normalize the url

    %HTTPoison.Response {
      body: body,
      status_code: 200,
    } = HTTPoison.get!(url)

    document = body
               |> Floki.parse_document!

    # find the name
    [{"span", _, [name]}] = document
                            |> Floki.find("#showview-content-header")
                            |> Floki.find(".ch-left")
                            |> Floki.find(".ellipsis")
                            |> Floki.find("span")

    name = name
           |> String.trim()

    IO.puts("[shows] adding show '#{name}'")

    Repo.transaction(fn ->
      show = %Show {
        name: name,
        url: url,
        lang: lang,
      }
      |> Repo.insert!(on_conflict: override)

      # find seasons
      seasons = document
                |> Floki.find(".list-of-seasons")
                |> Floki.find(".season")

      seasons
      |> Enum.each(fn (cur) ->
        name = cur
               |> Floki.find(".season-dropdown")

        name = if length(name) == 0 do
          show.name
        else
          [{"a", _, [name]}] = name
          name
        end

        name = name
               |> String.trim()

        if String.contains?(name, "Russian")
        || String.contains?(name, "Chinese")
        || String.contains?(name, "German")
        || String.contains?(name, "French")
        || String.contains?(name, "Spanish")
        || String.contains?(name, "Dub") do
          IO.puts("[shows] excluding season '#{name}'")
        else
          IO.puts("[shows] including season '#{name}'")

          season = %Season {
            name: name,
            show_id: show.id,
          }
          |> Repo.insert!(on_conflict: override)

          episodes = cur
                     |> Floki.find("ul")
                     |> Floki.find("a")

          episodes
          |> Enum.each(fn (cur) ->
            [{"span", _, [name]}] = cur
                                    |> Floki.find(".series-title")

            name = name
                   |> String.trim()

            [{"p", _, [desc]}] = cur
                                 |> Floki.find(".short-desc")

            desc = desc
                   |> String.trim()

            IO.puts("[shows] downloading '#{name} - #{desc}'")

            episode = %Episode {
              name: name,
              desc: desc,
              season_id: season.id,
            }
            |> Repo.insert!(on_conflict: override)

            # link to download
            {"a", [{"href", link} | _], _} = cur

            link = "https://crunchyroll.com" <> link
            uuid = UUID.generate()

            path = System.find_executable("youtube-dl")
            System.cmd(path, ["--sub-lang", lang, "--write-sub", "--skip-download", link, "-o", "/dev/shm/crun_subs+#{req_uuid}/#{uuid}"])

            if File.exists?("/dev/shm/crun_subs+#{req_uuid}/#{uuid}.#{lang}.ass") do
              IO.puts("[shows] parsing subs")

              source = File.read!("/dev/shm/crun_subs+#{req_uuid}/#{uuid}.#{lang}.ass")

              subtitle = %Subtitle {
                source: source,
                episode_id: episode.id,
              }
              |> Repo.insert!(on_conflict: override)

              # parse
              path = System.find_executable("python3")
              System.cmd(path, [File.cwd! <> "/py/subtract.py", "/dev/shm/crun_subs+#{req_uuid}/#{uuid}.#{lang}.ass", "/dev/shm/crun_subs+#{req_uuid}/#{uuid}.#{lang}.json"])

              if File.exists?("/dev/shm/crun_subs+#{req_uuid}/#{uuid}.#{lang}.json") do
                IO.ANSI.format([:green_background, IO.ANSI.format([:black, "[shows] writing events"])])
                |> IO.puts

                %{
                  "events" => events
                } = File.read!("/dev/shm/crun_subs+#{req_uuid}/#{uuid}.#{lang}.json")
                    |> Jason.decode!

                {_, events} = Enum.reduce(events, {0, []}, fn (cur, {idx, acc}) ->
                  entry = %{
                    id: UUID.generate(),
                    idx: idx,
                    val: cur,
                    subtitle_id: subtitle.id,
                    inserted_at: DateTime.utc_now,
                    updated_at: DateTime.utc_now,
                  }

                  {idx + 1, [entry | acc]}
                end)

                Event
                |> Repo.insert_all(events, on_conflict: override)

                path = System.find_executable("rm")
                System.cmd(path, ["/dev/shm/crun_subs+#{req_uuid}/#{uuid}.#{lang}.json"])
              else
                IO.ANSI.format([:red_background, IO.ANSI.format([:black, "[shows] couldn't parse subs"])])
                |> IO.puts

                if mode == :pristine do
                  raise "all-or-nothing contract broken"
                end
              end

              path = System.find_executable("rm")
              System.cmd(path, ["/dev/shm/crun_subs+#{req_uuid}/#{uuid}.#{lang}.ass"])
            else
              IO.ANSI.format([:red_background, IO.ANSI.format([:black, "[shows] couldn't get subs"])])
              |> IO.puts

              if mode == :pristine do
                raise "all-or-nothing contract broken"
              end
            end

            if Enum.random(0..2) == 2 do
              # big wait
              amt = 3000..9000
                    |> Enum.random()

              IO.puts("[shows] sleeping for #{Float.round(amt / 1000, 1)}s")

              amt
              |> Process.sleep()
            else
              # small wait
              amt = 300..900
                    |> Enum.random()

              IO.puts("[shows] sleeping for #{amt}ms")

              amt
              |> Process.sleep()
            end
          end)
        end
      end)

      {:ok}
    end, timeout: :infinity)
  end
end
