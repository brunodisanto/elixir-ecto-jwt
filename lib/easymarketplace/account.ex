defmodule Easymarketplace.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "accounts" do
    field :name, :string
    field :trading_name, :string
    field :document_number, :string
    field :locked?, :boolean
    field :state_id, :string
    field :address, :string
    field :address_line_2, :string
    field :state, :string
    field :postal_code, :string
    field :city, :string
    field :country, :string

    has_many :contacts, Easymarketplace.Contact
    has_many :users, Easymarketplace.User
    timestamps()
  end

  @required_fields ~w(name document_number)
  @optional_fields ~w(trading_name locked? state_id address address_line_2 state postal_code city country)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:contacts)
    |> cast_assoc(:users)
    |> unique_constraint(:document_number,
      name: :accounts_document_number_index,
      message: "Document number already assigned to another ACCOUNT.")
  end

end
