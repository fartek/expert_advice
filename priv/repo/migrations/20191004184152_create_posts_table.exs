defmodule ExpertAdviceStorage.Repo.Migrations.CreatePostsTable do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string, null: false)
      add(:slug, :string, null: false)
      add(:body, :text, null: false)
      add(:tags, {:array, :string}, null: false)

      add(:parent_id, references(:posts, type: :uuid))

      timestamps()
    end

    create(unique_index(:posts, ~w[slug]a))
    create(unique_index(:posts, ~w[title]a))
    create(index(:posts, ~w[parent_id]a))
    create(index(:posts, ~w[title body tags]a))
  end
end
