defmodule ExpertAdviceStorage.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:display_name, :string, null: false)

      add(:account_id, references(:accounts, type: :uuid))
      timestamps()
    end

    create(unique_index(:users, [:display_name]))
    create(unique_index(:users, [:account_id]))
  end
end
