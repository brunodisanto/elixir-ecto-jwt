defmodule Easymarketplace.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "contacts" do
    field :type, :string
    field :value, :string
    belongs_to :user, Easymarketplace.User , foreign_key: :user_id, type: :binary_id
    belongs_to :account, Easymarketplace.Account , foreign_key: :account_id, type: :binary_id
    timestamps()
  end

  @required_fields ~w(type value)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end
