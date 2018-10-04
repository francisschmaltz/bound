if config = Bound.config.auth
  Rails.application.config.middleware.use OmniAuth::Builder do
    # Replace with cas URL or other oAuth url
    provider :cas,  url:'https://cas.example.com'
  end
end
