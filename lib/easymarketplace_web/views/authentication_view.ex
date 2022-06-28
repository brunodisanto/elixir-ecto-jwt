defmodule EasymarketplaceWeb.AuthenticationView do
  use EasymarketplaceWeb, :view

  def render("create.json", %{response: token}) do
    %{token: token}
  end

  def render("error.json", %{response: response}) do
    %{error: response}
  end

end