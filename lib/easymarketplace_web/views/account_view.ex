defmodule EasymarketplaceWeb.AccountView do
    use EasymarketplaceWeb, :view

    def render("index.json", %{accounts: accounts}) do
        %{account: Enum.map(accounts, &account_json/1)}
    end

    def account_json(account) do
        %{
            name: account.name,
            trading_name: account.trading_name,
            document_number: account.document_number,
            locked?: account.locked?,
            state_id: account.state_id,
            address: account.address,
            address_line_2: account.address_line_2,
            state: account.state,
            postal_code: account.postal_code,
            city: account.city,
            country: account.country,
            contacts: Enum.map(account.contacts, &contact_json/1)
        }
    end

    def render("contacts.json", %{contacts: contacts}) do
        %{contacts: Enum.map(contacts, &contact_json/1)}
    end

    def contact_json(contact) do
        %{
            id: contact.id,
            type: contact.type,
            value: contact.value
        }
    end
end
