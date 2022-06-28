defmodule EasymarketplaceWeb.UserView do
  use EasymarketplaceWeb, :view

  def render("error.json", %{response: response}) do
    %{error: response}
  end

  def render("contacts.json", %{contacts: contacts}) do
    %{contacts: Enum.map(contacts, &contact_json/1)}
  end

  def render("index.json", %{user: user}) do
    %{
      name: user.name,
      email: user.email,
      document_number: user.document_number,
      document_type: user.document_type,
      active?: user.active?,
      contacts: Enum.map(user.contacts, &contact_json/1),
      account: user.account_id
    }
  end

  def contact_json(contact) do
    %{
        id: contact.id,
        type: contact.type,
        value: contact.value
    }
  end
end
