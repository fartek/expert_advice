defmodule ExpertAdviceStorage.Repo.Migrations.AddAuthorAndNumberOfViewsToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:author_id, references(:users, type: :uuid), null: false)
      add(:number_of_views, :integer, default: 0)
    end
  end
end
