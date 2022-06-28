defmodule Easymarketplace.Plugs.AuthenticatorPlug do
  use Guardian.Plug.Pipeline, otp_app: :easymarketplace,
                              module: Easymarketplace.Guardian,
                              error_handler: Easymarketplace.GuardianAuthErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end