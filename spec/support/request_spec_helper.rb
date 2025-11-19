module RequestSpecHelper
  def login(user)
    post session_path, params: { user: { email: user.email, password: "123456" } }
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
end
