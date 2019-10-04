defmodule ExpertAdviceStorage.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias ExpertAdviceStorage.Repo
      alias Ecto.Changeset
      import Ecto.Query
    end
  end

  setup tags do
    :ok = Sandbox.checkout(ExpertAdviceStorage.Repo)

    unless tags[:async] do
      Sandbox.mode(ExpertAdviceStorage.Repo, {:shared, self()})
    end

    :ok
  end
end
