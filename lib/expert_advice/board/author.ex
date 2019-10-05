defmodule ExpertAdvice.Board.Author do
  @moduledoc """
  The domain entity that represents an author of a question or an answer in a board
  """

  alias __MODULE__
  alias ExpertAdviceStorage.Identity, as: IdentityStorage

  @type t :: %Author{
          display_name: binary
        }

  defstruct [:display_name]

  @spec from_user(IdentityStorage.User.t()) :: Author.t()
  def from_user(user) do
    %Author{
      display_name: user.display_name
    }
  end
end
