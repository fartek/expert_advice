defmodule ExpertAdviceStorage.Repo do
  use Ecto.Repo,
    otp_app: :expert_advice,
    adapter: Ecto.Adapters.Postgres
end
