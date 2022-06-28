defmodule Easymarketplace.Repo.Migrations.AddTable do
  use Ecto.Migration

  def change do
    create table(:users)
    create table(:accounts)
    create table(:contacts)
  end
end
