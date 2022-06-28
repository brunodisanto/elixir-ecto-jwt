defmodule Easymarketplace.Repo.Migrations.CreateUserUniqIndex do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email], name: :users_email_index)
    create unique_index(:accounts, [:document_number], name: :accounts_document_number_index)
    # execute touch: "users", data: true, index: true
  end
end
