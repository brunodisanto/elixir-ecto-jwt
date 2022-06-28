defmodule Easymarketplace.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :name, :string
    field :email, :string
    field :document_number, :string
    field :document_type, :string
    field :password_hash, :string
    field :active?, :boolean
    has_many :contacts, Easymarketplace.Contact
    belongs_to :account, Easymarketplace.Account , foreign_key: :account_id, type: :binary_id
    timestamps()
  end

  @required_fields ~w(email password_hash)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:contacts)
    |> assoc_constraint(:account)
    |> unique_constraint(:email,
      name: :users_email_index,
      message: "Email already assigned to another USER.")
  end

end
