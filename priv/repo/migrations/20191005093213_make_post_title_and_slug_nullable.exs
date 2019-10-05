defmodule ExpertAdviceStorage.Repo.Migrations.MakePostTitleAndSlugNullable do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify(:title, :string, null: true)
      modify(:slug, :string, null: true)
    end
  end
end
