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

# Ensure transactional fixtures for cucumber
World(ActiveRecord::TestFixtures)
World(Rails.application.routes.url_helpers)
