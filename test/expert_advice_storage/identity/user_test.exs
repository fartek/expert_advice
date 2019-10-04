defmodule ExpertAdviceStorage.Identity.UserTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdviceStorage.Factory
  alias ExpertAdviceStorage.Identity.User

  setup do
    account = Factory.insert!(:account)

    %{
      valid_params: %{
        display_name: "valid_display_name",
        account_id: account.id
      },
      account: account
    }
  end

  describe "changeset/1" do
    test "creates a valid changeset for valid params", context do
      changeset = User.changeset(context.valid_params)
      assert changeset.valid?
      assert changeset.changes.display_name == "valid_display_name"
      assert changeset.changes.account_id == context.valid_params.account_id
    end

    test "throws away non-allowed properties", context do
      params = Map.put(context.valid_params, :random_param, "value")
      refute params |> User.changeset() |> Map.has_key?(:random_param)
    end

    test "requires specific properties", context do
      params_no_display_name = Map.delete(context.valid_params, :display_name)
      params_no_account_id = Map.delete(context.valid_params, :account_id)

      refute User.changeset(params_no_display_name).valid?
      refute User.changeset(params_no_account_id).valid?
    end

    test "assures no duplicate display names are created", context do
      account_id = context.valid_params.account_id
      Factory.insert!(:user, display_name: "valid_display_name", account_id: account_id)

      assert {:error, changeset} = context.valid_params |> User.changeset() |> Repo.insert()
      errors = Changeset.traverse_errors(changeset, & &1)
      assert %{display_name: [{"has already been taken", _}]} = errors
    end
  end
end
