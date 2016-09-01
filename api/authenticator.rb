authenticator :default do

  header 'X-Auth-Token', 'The API token to authenticate with', :example => 'f29a45f0-b6da-44ae-a029-d4e1744ebaee'

  error 'InvalidAPIToken', 'The API token provided is not valid', :attributes => {:token => 'The token that was provided'}

  lookup do
    if token = request.headers['X-Auth-Token']
      if api_token = APIToken.where(:token => token).first
        api_token
      else
        error 'InvalidAPIToken', :token => token
      end
    end
  end

  rule :default, 'APITokenRequired', 'An API token is required to access the resource.' do
    identity.is_a?(APIToken)
  end

end
