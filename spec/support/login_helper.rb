module LoginHelper
  # Logs in a user by posting to the SessionsController#create
  def login(user)
    post session_path, params: { user: { email: user.email, password: "123456" } }
  end
end

RSpec.configure do |config|
  config.include LoginHelper, type: :request
end
