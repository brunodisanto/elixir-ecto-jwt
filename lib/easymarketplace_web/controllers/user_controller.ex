defmodule EasymarketplaceWeb.UserController do
  use EasymarketplaceWeb, :controller
  import Ecto.Query
  alias Easymarketplace.{User, Repo, Contact, Account}
  alias Comeonin.Bcrypt

  def load_current_user_id(conn) do
    Guardian.Plug.current_resource(conn)
  end

  def load_current_user(conn) do
    user_id = load_current_user_id(conn)
    Repo.one(from u in User, where: u.id == ^user_id)
    |> Repo.preload(:account)
  end

  def insert(conn, params) do
    user_changeset = %User{
        email: params["email"],
        name: params["name"],
        document_number: params["document_number"],
        password_hash: Bcrypt.add_hash(params["password"])[:password_hash]
      }
      |> User.changeset

    user_changeset = 
    case params["contacts"] do
      nil -> user_changeset
      contacts ->
        contacts_changeset = 
        Enum.map contacts, fn c ->
          %Contact{type: c["type"], value: c["value"]}
          |> Contact.changeset
        end
        Ecto.Changeset.put_assoc(user_changeset, :contacts, contacts_changeset)
    end

    case Repo.insert(user_changeset) do
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

  def show(conn, params) do
    user_id = load_current_user_id(conn)
    user = Repo.one(from u in User, where: u.id == ^user_id)
           |> Repo.preload(:account)
           |> Repo.preload(:contacts)
    render(conn, "index.json", user: user)
  end

  def get_user_contacts(conn, params) do
    user_id = load_current_user_id(conn)
    contacts = Repo.all(from c in Contact, where: c.user_id == ^user_id)
    render(conn, "contacts.json", contacts: contacts)
  end

  def delete_user_contact(conn, params) do
    user_id = load_current_user_id(conn)
    contact = case Repo.one(from c in Contact, where: c.id == ^params["contact_id"] and c.user_id == ^user_id) do
      nil -> conn
        |> put_status(404)
        |> json(%{response: "Not found."})
      contact -> contact
    end
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

  def insert_user_contact(conn, params) do
    user_id = load_current_user_id(conn)
    contact_changeset = %Contact{
      type: params["type"],
      value: params["value"],
      user_id: user_id
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

  def update_user_contact(conn, params) do
    user_id = load_current_user_id(conn)
    contact = case Repo.one(from c in Contact, where: c.id == ^params["contact_id"] and c.user_id == ^user_id) do
      nil -> conn
        |> put_status(404)
        |> json(%{response: "Not found."})
      contact -> contact
    end
    contact_changeset = Repo.preload(contact, :user)
              |> Repo.preload(:account)
              |> build_contact_update_changeset(params)
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

  def build_contact_update_changeset(contact, params) do
    Contact.changeset(contact, %{
      type: params["type"],
      value: params["value"]
    })
  end



end