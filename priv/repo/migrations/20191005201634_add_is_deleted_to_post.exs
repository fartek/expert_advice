defmodule ExpertAdviceStorage.Repo.Migrations.AddIsDeletedToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:is_deleted, :boolean, default: false, null: false)
    end
  end
end
