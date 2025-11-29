require 'simplecov'
SimpleCov.start 'rails' do
  command_name 'Cucumber'
  coverage_dir 'coverage/cucumber'
  add_filter '/features/'
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/db/'
  add_filter '/jobs/'
  add_filter '/mailers/'
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_filter '/app/services/spotify_client.rb'
end

require 'cucumber/rails'
require 'capybara/rails'

# Enable rack_session_access for direct session manipulation
if Rails.env.test?
  require 'rack_session_access/capybara'
end

# Ensure transactional fixtures for cucumber
World(ActiveRecord::TestFixtures)
World(Rails.application.routes.url_helpers)

require 'rspec/mocks'
World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup
end

After do
  RSpec::Mocks.verify
  RSpec::Mocks.teardown
end
