if config = Bound.config.auth
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider config.strategy, config.client_key, config.client_secret, :scopes => config.scopes
  end
end
