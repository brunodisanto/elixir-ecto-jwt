defmodule Easymarketplace.Repo do
  use Ecto.Repo, otp_app: :easymarketplace, adapter: Mongo.Ecto
end
