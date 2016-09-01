shared_action :validation_error do
  error 'ValidationError', "A validation error occurred", :attributes => {:errors => "An array of errors"}
end
