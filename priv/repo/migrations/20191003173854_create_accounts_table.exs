defmodule ExpertAdviceStorage.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:username, :string, null: false)
      add(:hashed_password, :string, null: false)

      timestamps()
    end

    create(unique_index(:accounts, ~w[username]a))
  end
end
