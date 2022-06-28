defmodule EasymarketplaceWeb.AccountController do
  use EasymarketplaceWeb, :controller
  import Ecto.Query
  alias Easymarketplace.{Account, Repo, Contact, User}

  def load_current_user(conn) do
    user_id = Guardian.Plug.current_resource(conn)
    Repo.one(from u in User, where: u.id == ^user_id)
    |> Repo.preload(:account)
  end

  def insert(conn, params) do
    user = load_current_user(conn)

    case user.account_id do
      nil -> insert_account(user, conn, params)
      _ ->
        conn
        |> put_status(409)
        |> json(%{response: "User assigned to another ACCOUNT"})
    end
  end

  def insert_account(user, conn, params) do
    account_changeset = build_account_insert_changeset(params, user)

    case Repo.insert(account_changeset) do
      {:ok, account} ->
        send_resp(conn, :created, "")
        #use only if want to enable multiple accounts per user
        #associate_current_user_account(conn, account)
      {:error, %Ecto.Changeset{} = changeset} ->
        return_message = Ecto.Changeset.traverse_errors(changeset, fn
              {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
              msg -> msg
        end)
        conn
        |> put_status(400)
        |> json(%{errors: return_message})
      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{response: "Error! Contact system admin."})
    end

  end

  def build_account_insert_changeset(params, user) do
    account_changeset = %Account{
      name: params["name"],
      trading_name: params["trading_name"],
      document_number: params["document_number"],
      #locked?: params["locked"],
      state_id: params["state_id"],
      address: params["address"],
      address_line_2: params["address_line_2"],
      state: params["state"],
      postal_code: params["postal_code"],
      city: params["city"],
      country: params["country"],
      users: [user]
    }
    |> Account.changeset

    case params["contacts"] do
      nil -> account_changeset
      contacts ->
        contacts_changeset = 
        Enum.map contacts, fn c ->
          %Contact{type: c["type"], value: c["value"]}
          |> Contact.changeset
        end
        Ecto.Changeset.put_assoc(account_changeset, :contacts, contacts_changeset)
    end
  end

  #use only if user can have more than one account. disabled by now
  # def associate_current_user_account(conn, account) do
  #   %UserAccounts{user_id: Guardian.Plug.current_resource(conn), account_id: account.id}
  #   |> UserAccounts.changeset
  #   |> Repo.insert_or_update()
  #   send_resp(conn, :created, "")
  # end

  def index(conn, params) do
    user = load_current_user(conn)
    account = Repo.preload(user.account, :contacts) 
    render(conn, "index.json", accounts: [account])
  end

  def update(conn, params) do
    user = load_current_user(conn)

    case params["document_number"] do
      nil ->
        conn
        |> put_status(422)
        |> json(%{response: "Field 'document_number' is mandatory."})
      _-> check_permission_account(conn, params, user)
    end

  end

  defp check_permission_account(conn, params, user) do
    case user.account.document_number == params["document_number"] do
      true -> do_update_account(conn, params, user)
      false ->
        conn
        |> put_status(403)
        |> json(%{response: "Current user does not have permission to update given account."})
    end
  end

  defp build_account_update_changeset(account, params) do
    Account.changeset(account, %{
      name: params["name"],
      trading_name: params["trading_name"],
      #locked?: params["locked"],
      state_id: params["state_id"],
      address: params["address"],
      address_line_2: params["address_line_2"],
      state: params["state"],
      postal_code: params["postal_code"],
      city: params["city"],
      country: params["country"]
    })
  end

  def build_contact_update_changeset(contact, params) do
    Contact.changeset(contact, %{
      type: params["type"],
      value: params["value"]
    })
  end

  defp do_update_account(conn, params, user) do
    account = user.account
    account = Repo.preload(account, :contacts)
    account = Repo.preload(account, :users)

    account_changeset = build_account_update_changeset(account, params)

    case Repo.update(account_changeset) do
      {:ok, _} ->
        conn
        |> put_status(201)
        |> json(%{response: "Updated!"})
      {:error, %Ecto.Changeset{} = changeset} ->
        return_message = Ecto.Changeset.traverse_errors(changeset, fn
              {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
              msg -> msg
        end)
        conn
        |> put_status(400)
        |> json(%{errors: return_message})
      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{response: "Error! Contact system admin."})
    end
  end

  def update_account_contact(conn, params) do
    case params["contact_id"] do
      nil ->
        conn
        |> put_status(422)
        |> json(%{response: "Field 'contact_id' is mandatory."})
      _-> check_permission_update_contact(conn, params)
    end
  end

  defp check_permission_update_contact(conn, params) do
    curr_user = load_current_user(conn)
    case Repo.one(from c in Contact, where: c.id == ^params["contact_id"] and c.account_id == ^curr_user.account.id) do
      nil -> conn
        |> put_status(404)
        |> json(%{response: "Not found."})
      contact -> contact
    end
    |> Repo.preload(:account)
    |> Repo.preload(:user)
    |> do_update_contact(conn, params)
  end

  defp do_update_contact(contact, conn, params) do
    contact_changeset = build_contact_update_changeset(contact, params)
    case Repo.update(contact_changeset) do
      {:ok, _} ->
        conn
        |> put_status(201)
        |> json(%{response: "Updated!"})
      {:error, %Ecto.Changeset{} = changeset} ->
        return_message = Ecto.Changeset.traverse_errors(changeset, fn
              {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
              msg -> msg
        end)
        conn
        |> put_status(400)
        |> json(%{errors: return_message})
      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{response: "Error! Contact system admin."})
    end
  end


  def delete_account_contact(conn, params) do
    curr_user = load_current_user(conn)
    case Repo.one(from c in Contact, where: c.id == ^params["contact_id"] and c.account_id == ^curr_user.account.id) do
      nil -> conn
        |> put_status(404)
        |> json(%{response: "Not found."})
      contact -> contact
    end
    |> Repo.preload(:account)
    |> Repo.preload(:user)
    |> do_delete_contact(conn)
  end

  defp do_delete_contact(contact, conn) do
    case Repo.delete(contact) do
      {:ok, _} ->
        conn
        |> put_status(201)
        |> json(%{response: "Deleted!"})
      {:error, %Ecto.Changeset{} = changeset} ->
        return_message = Ecto.Changeset.traverse_errors(changeset, fn
              {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
              msg -> msg
        end)
        conn
        |> put_status(400)
        |> json(%{errors: return_message})
      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{response: "Error! Contact system admin."})  
    end
  end

  def insert_account_contact(conn, params) do
    curr_user = load_current_user(conn)
    user_account = curr_user.account
    contact_changeset = %Contact{
        type: params["type"],
        value: params["value"],
        account_id: user_account.id
      }
      |> Contact.changeset
    case Repo.insert(contact_changeset) do
      {:ok, _} ->
        send_resp(conn, :created, "")
      {:error, %Ecto.Changeset{} = changeset} ->
        return_message = Ecto.Changeset.traverse_errors(changeset, fn
              {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
              msg -> msg
        end)
        conn
        |> put_status(400)
        |> json(%{errors: return_message})
      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{response: "Error! Contact system admin."})
    end
  end

  def get_account_contacts(conn, params) do
    user = load_current_user(conn)
    account_id = user.account_id
    contacts = Repo.all(from c in Contact, where: c.account_id == ^user.account_id)
    render(conn, "contacts.json", contacts: contacts)
  end

 end