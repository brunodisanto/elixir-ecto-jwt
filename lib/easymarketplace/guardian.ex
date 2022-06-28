defmodule Easymarketplace.Guardian do
  use Guardian, otp_app: :easymarketplace

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.sub)}
  end

  def resource_from_claims(claims) do
    {:ok, claims["user_id"]} # {:ok, resource} or {:error, reason}
  end

  def generate_token(%{"email" => email, "password" => password}) do
    Easymarketplace.User
    |> Easymarketplace.Repo.get_by(email: email)
    |> Comeonin.Bcrypt.check_pass(password)
    |> create_user_token
  end
  def generate_token(params), do: {:error, %{invalid_params: params}}

  defp create_user_token({:error, _message}), do: {:error, %{unauthorized: "Access denied due to invalid credentials"}}
  defp create_user_token({:ok, user}),
    do: Easymarketplace.Guardian.encode_and_sign( %{sub: "user_id"}, %{user_id: user.id})

end
