defmodule ExpertAdviceStorage.Factory do
  alias ExpertAdviceStorage.Repo
  alias ExpertAdviceStorage.Board.Post
  alias ExpertAdviceStorage.Identity.{Account, User}

  def build(:user), do: %User{display_name: "display_name", account_id: "account_id"}

  def build(:account) do
    %Account{
      username: "user",
      password: "pass",
      hashed_password:
        "$pbkdf2-sha512$160000$EPPmJkQnzDrWGJU0/hWJKg$yGzEKq4tJXbP16v6XSgVvrYBEy//Z1dDsVkd.yR7Lu/iU77hUPirAkqIroSUIa8R/pvzWE08daOiPJ/n2MuOCA"
    }
  end

  def build(:post) do
    %Post{
      title: "title",
      body: "body",
      slug: "slug",
      tags: []
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
