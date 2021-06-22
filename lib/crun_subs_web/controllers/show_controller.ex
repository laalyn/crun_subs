defmodule CrunSubsWeb.ShowController do
  use CrunSubsWeb, :controller

  alias CrunSubs.Shows

  alias CrunSubsWeb.FallbackController

  action_fallback CrunSubsWeb.FallbackController

  alias Ecto.UUID

  def add(conn, %{"url" => url, "lang" => lang, "mode" => mode, "override" => override}) do
    try do
      spawn(fn ->
        req_uuid = UUID.generate()

        path = System.find_executable("mkdir")
        System.cmd(path, ["/dev/shm/crun_subs+#{req_uuid}"])

        {:ok, {:ok}} = Shows.add_show(url, lang, mode, override, req_uuid)

        path = System.find_executable("rm")
        System.cmd(path, ["-r", "/dev/shm/crun_subs+#{req_uuid}"])
      end)

      conn
      |> put_status(:accepted)
      |> json(%{status: "started"})
    rescue err ->
      IO.inspect(__STACKTRACE__)
      FallbackController.call(conn, {:error, err})
    end
  end
end
