defmodule Easymarketplace.UserAccounts do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "user_accounts" do
    belongs_to :user, Easymarketplace.User , foreign_key: :user_id, type: :binary_id
    belongs_to :account, Easymarketplace.Account , foreign_key: :account_id, type: :binary_id
    timestamps()
  end

  @required_fields ~w(user_id account_id)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end
