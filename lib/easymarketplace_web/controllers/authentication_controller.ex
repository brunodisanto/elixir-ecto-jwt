defmodule EasymarketplaceWeb.AuthenticationController do
  use EasymarketplaceWeb, :controller

  def authenticate(conn, params) do
    with {:ok, token, content } <- Easymarketplace.Guardian.generate_token(params)
    do
      conn
      |> put_status(:ok)
      |> json(%{token: token})
    else
    {:error, _} ->
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid credentials."})
	end
  end
 end
