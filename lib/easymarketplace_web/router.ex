defmodule EasymarketplaceWeb.Router do
  use EasymarketplaceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug Easymarketplace.Plugs.AuthenticatorPlug
  end

  scope "/", EasymarketplaceWeb do
    pipe_through :api
    post "/authenticate", AuthenticationController, :authenticate

    #this one doesnt need to be authenticated
    scope "/user" do
      post "/", UserController, :insert
    end

    scope "/user" do
        pipe_through :api_auth
        get "/", UserController, :show
        scope "/contact" do
          get "/", UserController, :get_user_contacts
          post "/", UserController, :insert_user_contact
          put "/", UserController, :update_user_contact
          delete "/:contact_id", UserController, :delete_user_contact
        end
    end

    scope "/account" do
      pipe_through :api_auth
      post "/", AccountController, :insert
      get "/", AccountController, :index
      put "/", AccountController, :update
      scope "/contact" do
        post "/", AccountController, :insert_account_contact
        put "/", AccountController, :update_account_contact
        delete "/:contact_id", AccountController, :delete_account_contact
        get "/", AccountController, :get_account_contacts
      end
    end
  end
end
